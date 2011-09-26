jast = require '../'

serializeType = (v) ->
	if v in [Boolean, String, Number]
		t = v.name
	else if v == jast.Node
		t = 'node'
	else if v?.constructor == Array
		t = 'Array<_' + serializeType(v[0]) + '_>'
	else if typeof v == 'object'
		t = '{'
		for k, prop of v
			(t += '_' + serializeType(prop) + '_ ' + k + ', ')
		t = t.slice(0, -2) + '}'
	else
		t = '{}'
	return t

writeType = (name, type) ->
	console.log '*    **' + name + '**: ' + serializeType(type)

console.log '\n### Contexts'
writeType(name, type) for name, type of jast.types when jast.isContext(type: name)

console.log '\n### Literals'
writeType(name, type) for name, type of jast.types when jast.isLiteral(type: name)

console.log '\n### Operations'
writeType(name, type) for name, type of jast.types when jast.isOp(type: name)

console.log '\n### Expressions'
writeType(name, type) for name, type of jast.types when jast.isExpr(type: name)

console.log '\n### Statements'
writeType(name, type) for name, type of jast.types when jast.isStat(type: name)