# AST Schema Definitions
# ----------------------

exports.populate = (jast) ->

	# AST definitions.
	jast.types = {}
	jast.define = (name, args) ->
		jast.types[name] = args

	# "Node" type for schema definition.
	Node = jast.Node = {}

	# Define "contexts", aka scopes, such as the script context and 
	# function closure context.

	jast.isContext = (n) -> n?.type.match(/-context$/)

	jast.define "script-context",
		stats: Array(Node)
	jast.define "closure-context",
		name: String
		args: Array(String)
		stats: Array(Node)

	# Define all possible JavaScript literals.

	jast.isLiteral = (n) -> n?.type.match(/-literal$/)

	jast.define "num-literal",
		value: Number
	jast.define "str-literal",
		value: String
	jast.define "obj-literal",
		props: Array(value: String, expr: Node)
	jast.define "array-literal",
		exprs: Array(Node)
	jast.define "undef-literal"
	jast.define "null-literal"
	jast.define "boolean-literal",
		value: Boolean
	jast.define "func-literal",
		closure: Node
	jast.define "regexp-literal",
		expr: String
		flags: String

	# Define all unary/binary operations.

	jast.isOp = (n) -> n?.type.match(/-op-expr$/)
	jast.isUnaryOp = (n) -> jast.isOp(n) and n.expr
	jast.isBinaryOp = (n) -> jast.isOp(n) and n.left and n.right

	for x in ['num', 'neg', 'not', 'bit-not', 'typeof', 'void']
		jast.define "#{x}-op-expr",
			expr: Node

	for x in ['lt', 'lte', 'gt', 'gte', 'eq', 'eqs', 'neq', 'neqs',
	 'add', 'sub', 'mul', 'div', 'mod', 'lsh', 'rsh', 'bit-and', 'bit-or', 'bit-xor',
	 'or', 'and', 'instanceof', 'in', 'typeof', 'void', 'seq']
	 	jast.define "#{x}-op-expr",
	 		left: Node
	 		right: Node

	# Define all expression nodes.

	jast.isExpr = (n) -> n?.type.match(/-expr$/)

	jast.define "this-expr"
	jast.define "call-expr"
		expr: Node
		args: Array(Node)
	jast.define "new-expr",
		constructor: Node
		args: Array(Node)
	jast.define "if-expr"
		expr: Node
		thenExpr: Node
		elseExpr: Node
	jast.define "scope-ref-expr",
		value: String
	jast.define "static-ref-expr",
		base: Node
		value: String
	jast.define "dyn-ref-expr",
		base: Node
		index: Node
	jast.define "static-method-call-expr",
		base: Node
		value: String
		args: Array(Node)
	jast.define "dyn-method-call-expr",
		base: Node
		index: Node
		args: Array(Node)
	jast.define "scope-delete-expr",
		value: String
	jast.define "static-delete-expr",
		base: Node
		value: String
	jast.define "dyn-delete-expr",
		base: Node
		index: Node
	jast.define "scope-assign-expr",
		value: String
		expr: Node
	jast.define "static-assign-expr",
		base: Node
		value: String
		expr: Node
	jast.define "dyn-assign-expr",
		base: Node
		index: Node
		expr: Node
	jast.define "scope-inc-expr",
		pre: Boolean
		inc: Number
		value: String
	jast.define "static-inc-expr",
		pre: Boolean
		inc: Number
		base: Node
		value: String
	jast.define "dyn-inc-expr",
		pre: Boolean
		inc: Number
		base: Node
		index: Node

	# Defines statements.

	jast.isStat = (n) -> n?.type.match(/-stat$/)

	jast.define "block-stat",
		stats: Array(Node)
	jast.define "expr-stat",
		expr: Node
	jast.define "ret-stat",
		expr: Node
	jast.define "if-stat",
		expr: Node
		thenStat: Node
		elseStat: Node
	jast.define "while-stat",
		expr: Node
		stat: Node
	jast.define "do-while-stat",
		expr: Node
		stat: Node
	jast.define "for-stat",
		init: Node
		expr: Node
		step: Node
		stat: Node
	jast.define "for-in-stat",
		isvar: Boolean
		value: String
		expr: Node
		stat: Node
	jast.define "switch-stat",
		expr: Node
		cases: Array(match: Node, stat: Node)
	jast.define "throw-stat",
		expr: Node
	jast.define "try-stat",
		tryStat: Node
		catchBlock: {value: String, stat: Node}
		finallyStat: Node
	jast.define "var-stat",
		vars: Array(value: String, expr: Node)
	jast.define "defn-stat",
		closure: Node
	jast.define "label-stat",
		name: String
		stat: Node
	jast.define "break-stat",
		label: String
	jast.define "continue-stat",
		label: String