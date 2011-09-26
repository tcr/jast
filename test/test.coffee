jast = require '../jast'
util = require 'util'

ast = jast.parse 'function a() { alert("hello world"); alert(5 + 6 * 7 == 9); }; a()'
console.log util.inspect(ast, false, null)

console.log jast.numbers(ast)