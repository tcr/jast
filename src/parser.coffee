# AST Parser
# ----------

exports.populate = (jast) ->
	preparser = require('./parser-base.js')

	# Node shorthand. Each node has a type and line number property.
	node = (type, ln, props = {}) ->
		ret = {type, ln}
		(ret[k] = v) for k, v of props
		return ret

	# Parse the output of parser-base into our AST.
	genAst = (o) ->
		# in order of parser-base
		switch o[0]
			when "atom", "name"
				[_, ln, value] = o
				return switch value
					when "true" then node("boolean-literal", ln, value: true)
					when "false" then node("boolean-literal", ln, value: false)
					when "this" then node("this-expr", ln)
					when "null" then node("null-literal", ln)
					when "undefined" then node("undef-literal", ln)
					else node("scope-ref-expr", ln, value: value)
			when "num"
				[_, ln, value] = o
				return node("num-literal", ln, value: value)
			when "string"
				[_, ln, value] = o
				return node("str-literal", ln, value: value)
			when "array"
				[_, ln, elems] = o
				return node("array-literal", ln, exprs: (genAst(x) for x in elems))
			when "object"
				[_, ln, elems] = o
				return node("obj-literal", ln, props: ({value: k, expr: genAst(v)} for [k, v] in elems))
			when "regexp"
				[_, ln, expr, flags] = o
				return node("regexp-literal", ln, expr: expr, flags: flags)

			when "assign"
				[_, ln, op, place, val] = o
				val = ["binary", ln, op, place, val] unless op == true
				return switch place[0]
					when "name" then node("scope-assign-expr", ln, value: place[2], expr: genAst(val))
					when "dot" then node("static-assign-expr", ln, base: genAst(place[2]), value: place[3], expr: genAst(val))
					when "sub" then node("dyn-assign-expr", ln, base: genAst(place[2]), index: genAst(place[3]), expr: genAst(val))
			when "binary"
				[_, ln, op, lhs, rhs] = o
				map =
					"+": "add-op-expr"
					"-": "sub-op-expr"
					"*": "mul-op-expr"
					"/": "div-op-expr"
					"%": "mod-op-expr"
					"<": "lt-op-expr"
					">": "gt-op-expr"
					"<=": "lte-op-expr"
					">=": "gte-op-expr"
					"==": "eq-op-expr"
					"===": "eqs-op-expr"
					"!=": "neq-op-expr"
					"!==": "neqs-op-expr"
					"||": "or-op-expr"
					"&&": "and-op-expr"
					"<<": "lsh-op-expr"
					">>": "rsh-op-expr"
					"&": "bit-or-op-expr"
					"|": "bit-or-op-expr"
					"^": "bit-xor-op-expr"
					"instanceof": "instanceof-op-expr"
					"in": "in-op-expr"
				return node(map[op], ln, left: genAst(lhs), right: genAst(rhs))
			when "unary-postfix"
				[_, ln, op, place] = o
				inc = if op == "++" then 1 else -1
				switch place[0]
					when "name" then node("scope-inc-expr", ln, pre: false, inc: inc, value: place[2])
					when "dot" then node("static-inc-expr", ln, pre: false, inc: inc, base: genAst(place[2]), value: place[3])
					when "sub" then node("dyn-inc-expr", ln, pre: false, inc: inc, base: genAst(place[2]), index: genAst(place[3]))
			when "unary-prefix"
				[_, ln, op, place] = o
				return switch op
					when "+" then node("num-op-expr", ln, expr: genAst(place))
					when "-" then node("neg-op-expr", ln, expr: genAst(place))
					when "~" then node("bit-op-expr", ln, expr:genAst(place))
					when "++", "--"
						inc = if op == "++" then 1 else -1
						switch place[0]
							when "name" then node("scope-inc-expr", ln, pre: true, inc: inc, value: place[2]]
							when "dot" then node("static-inc-expr", ln, pre: true, inc: inc, base: genAst(place[2]), value: place[3])
							when "sub" then node("dyn-inc-expr", ln, pre: true, inc: inc, base: genAst(place[2]), index: genAst(place[3]))
					when "!" then node("not-op-expr", ln, expr: genAst(place))
					when "void" then node("void-op-expr", ln, expr: genAst(place))
					when "typeof" then node("typeof-op-expr", ln, expr: genAst(place))
					when "delete"
						switch place[0]
							when "name" then node("scope-delete-expr", ln, value: place[2])
							when "dot" then node("static-delete-expr", ln, base: genAst(place[2]), value: place[3])
							when "sub" then node("dyn-delete-expr", ln, base: genAst(place[2]), index: genAst(place[3]))
			when "call"
				[_, ln, func, args] = o
				switch func[0]
					when "dot"
						[_, ln, base, value] = func
						return node("static-method-call-expr", ln, base: genAst(base), value: value, args: (genAst(x) for x in args))
					else
						return node("call-expr", ln, expr: genAst(func), args: (genAst(x) for x in args))
			when "dot"
				[_, ln, obj, attr] = o
				return node("static-ref-expr", ln, base: genAst(obj), value: attr)
			when "sub"
				[_, ln, obj, attr] = o
				return node("dyn-ref-expr", ln, base: genAst(obj), index: genAst(attr))
			when "seq"
				[_, ln, form1, result] = o
				return node("seq-op-expr", ln, left: genAst(form1), right: genAst(result))
			when "conditional"
				[_, ln, test, thn, els] = o
				return node("if-expr", ln, expr: genAst(test), thenExpr: genAst(thn), elseExpr: genAst(els))
			when "function"
				[_, ln, name, args, stats] = o
				return node("func-literal", ln, closure: node("closure-context", ln, name: name, args: args, stats: (genAst(x) for x in stats)))
			when "new"
				[_, ln, func, args] = o
				return node("new-expr", ln, constructor: genAst(func), args: (genAst(x) for x in args))

			when "toplevel"
				[_, ln, stats] = o
				return node("script-context", ln, stats: (genAst(x) for x in stats))
			when "block"
				[_, ln, stats] = o
				stats = stats or []
				return node("block-stat", ln, stats: (genAst(x) for x in stats))
			when "stat"
				[_, ln, form] = o
				return node("expr-stat", ln, expr: genAst(form))
			when "label"
				[_, ln, name, form] = o
				return node("label-stat", ln, name: name, stat: genAst(form))
			when "if"
				[_, ln, test, thn, els] = o
				return node("if-stat", ln, expr: genAst(test), thenStat: genAst(thn), elseStat: (if els then genAst(els) else null))
			#when "with"
			#	[_, ln, obj, body] = o
			when "var"
				[_, ln, bindings] = o
				return node("var-stat", ln, vars: ({value: k, expr: (if v then genAst(v) else null)} for [k, v] in bindings))
			when "defun"
				[_, ln, name, args, stats] = o
				return node("defn-stat", ln, closure: node("closure-context", ln, name: name, args: args, stats: (genAst(x) for x in stats)))
			when "return"
				[_, ln, value] = o
				return node("ret-stat", ln, expr: (if value then genAst(value) else null))
			#when "debugger"
			#	[_, ln] = o
			when "try"
				[_, ln, body, ctch, fnlly] = o
				return node "try-stat", ln,
					tryStat: node("block-stat", ln, stats: (genAst(x) for x in body))
					catchBlock: (if ctch
						[label, stats] = ctch
						{value: label, stat: node("block-stat", ln, stats: (genAst(x) for x in stats))})
					finallyStat: (if fnlly
						node("block-stat", ln, stats: (genAst(x) for x in fnlly)))
			when "throw"
				[_, ln, expr] = o
				return node("throw-stat", ln, expr: genAst(expr))
			when "break"
				[_, ln, label] = o
				return node("break-stat", ln, label: label)
			when "continue"
				[_, ln, label] = o
				return node("continue-stat", ln, label: label)
			when "while"
				[_, ln, cond, body] = o
				return node("while-stat", ln, expr: genAst(cond), stat: genAst(body))
			when "do"
				[_, ln, cond, body] = o
				return node("do-while-stat", ln, expr: genAst(cond), stat: genAst(body))
			when "for"
				[_, ln, init, cond, step, body] = o
				return node "for-stat", ln,
					init: if init then genAst(init) else null
					expr: if cond then genAst(cond) else null
					step: if step then genAst(step) else null
					stat: if body then genAst(body) else []
			when "for-in"
				[_, ln, vari, name, obj, body] = o
				return node "for-in-stat", ln,
					isvar: vari
					value: name
					expr: genAst(obj)
					stat: genAst(body)
			when "switch"
				[_, ln, val, body] = o
				return node "switch-stat", ln,
					expr: genAst(val)
					cases: {
						match: (if cse then genAst(cse) else null),
						stat: node("block-stat", ln, stats: (genAst(x) for x in stats))
						} for [cse, stats] in body

			else
				console.log("[ERROR] Can't generate AST for node \"#{o[0]}\"")

	# Parses a block of code, returning an error if invalid.
	# The returned code is the AST type "script-context".
	jast.parse = (str) ->
		try
			ast = preparser.parse(str)
		catch e
			throw new Error("Parsing error: " + e)
		return genAst(ast)
