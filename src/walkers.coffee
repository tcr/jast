# AST Walkers
# -----------

jast = require './jast'

# Walk the AST, starting from the given node and including all child
# nodes, and return an cumulative array. The second argument passed to
# jast.walk can be a function, called once for each node: it can return
# an array of data (such as returning the value of each string node), or
# call the walker with itself as the second argument, to be called again
# on all children of that node. The resulting array is the concat-ed 
# result of all data returned.
jast.walk = (n, f = jast.walk) ->
	check = (type, value) =>
		return if type == jast.Node
			f(value)
		else if type?.constructor == Array
			[].concat((check(type[0], pvalue) for pvalue in value)...)
		else if typeof type == 'object'
			[].concat((check(ptype, value[prop]) for prop, ptype of type)...)
		else
			[]

	return check(jast.types[n.type], n)

# Return an array of all strings used in this node.
jast.strings = (n, f = jast.strings) ->
	if n.type == "str-literal" then return [n.value]
	return jast.walk(n, f)

# Return an array of all numbers used in this node.
jast.numbers = (n, f = jast.numbers) ->
	if n.type == "num-literal" then return [n.value]
	return jast.walk(n, f)

# Return an array of all regular expressions used in this node.
jast.regexps = (n, f = jast.regexps) ->
	if n.type == "regexp-literal" then return [[n.expr, n.flags]]
	return jast.walk(n, f)

# Find all child contexts, including the current context.
jast.contexts = (ctx, f = jast.contexts) ->
	if jast.isContext(ctx) then return [ctx].concat(f(ctx.stat))
	return jast.walk(ctx, f)

# Find all variables declared in this node and child scopes.
jast.vars = (n, f = jast.vars) ->
	switch n.type
		when "closure-context"
			return (if n.name? then [n.name] else []).concat(n.args, f(n.stat))
		when "var-stat"
			return (k for [k, v] in n.vars).concat((f(v) for [k, v] in n.vars when v)...)
		when "for-in-stat"
			return (if n.isvar then [n.value] else []).concat(f(n.stat))
		when "try-stat"
			return f(n.tryStat).concat(
				(if n.catchBlock then [n.catchBlock.value].concat(f(n.catchBlock.stat))
				else []),
				(if n.finallyStat then f(x) else []))
		when "scope-ref-expr"
			return if n.value == "arguments" then ["arguments"] else []
		when "defn-stat"
			return if n.closure.name? then [n.closure.name] else []
		else
			return jast.walk(n, f)

# Find all varaibles declared in this node's local scope.
jast.localVars = (n, f = jast.localVars) ->
	if n.type in ["script-context", "closure-context"] then return []
	return jast.vars(n, f)

# Returns true if this closure uses the implicit "arguments" variable.
jast.usesArguments = (closure) ->
	return "arguments" in jast.localVars(closure.stat)

# Finds all local references used in this node (variables or globals).
jast.localRefs = (n, f = jast.localRefs) ->
	switch n.type
		when "script-context", "closure-context"
			return []
		when "scope-ref-expr", "scope-assign-expr", "scope-delete-expr"
			return [value]
		else
			return jast.walk(n, f)

# Unique-set utility.
set = (a) ->
	o = {}; r = []
	o[k] = true for k in a
	r.push(k) for k, _ of o
	return r

# Finds all local references used in this node that are defined in
# parent scopes, or are not defined at all.
jast.localUndefinedRefs = (ctx) ->
	refs = jast.localRefs(ctx.stat)
	vars = jast.localVars(ctx.stat)
	return set(k for k in refs when k not in vars)

# Finds all undefined references in this node, including child scopes.
jast.undefinedRefs = (o) ->
	return set([].concat((jast.localUndefinedRefs(ctx) for ctx in jast.contexts(o))...))