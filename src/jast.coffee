# jast, JavaScript AST parser and tools
#
# You can parse a JavaScript string using jast.parse(code), which
# returns a JSON AST tree (or throws a parser error). jast then
# includes several walkers to analyze the tree.
#
# View the README for definitions for all possible AST nodes.
#
# jast includes the wonderful parser from UglifyJS by mishoo.
# jast is released under the BSD license.

jast = exports

# Internal dependencies.
require('./parser').populate jast
require('./nodes').populate jast
require('./walkers').populate jast
