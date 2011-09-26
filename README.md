# jast, a JavaScript parser, AST, and tools

Credit to UglifyJS by mishoo for the parser base.
jast is released under the modified BSD license.

## AST Definition

Each AST node is a JSON hash with the property "type" corresponding to the node type ("script-context", "sub-op-expr", etc) and the property "ln" corresponding to line number. Each node has properties about the node as described below:

### Contexts
*    **script-context**: {_node_ stat}
*    **closure-context**: {_String_ name, _Array<_String_>_ args, _node_ stat}

### Literals
*    **num-literal**: {_Number_ value}
*    **str-literal**: {_String_ value}
*    **obj-literal**: {_Array<_{_String_ value, _node_ expr}_>_ props}
*    **array-literal**: {_Array<_node_>_ exprs}
*    **undef-literal**: {}
*    **null-literal**: {}
*    **boolean-literal**: {_Boolean_ value}
*    **func-literal**: {_node_ closure}
*    **regex-literal**: {_String_ expr, _String_ flags}

### Operations
*    **num-op-expr**: {_node_ expr}
*    **neg-op-expr**: {_node_ expr}
*    **not-op-expr**: {_node_ expr}
*    **bit-not-op-expr**: {_node_ expr}
*    **typeof-op-expr**: {_node_ left, _node_ right}
*    **void-op-expr**: {_node_ left, _node_ right}
*    **lt-op-expr**: {_node_ left, _node_ right}
*    **lte-op-expr**: {_node_ left, _node_ right}
*    **gt-op-expr**: {_node_ left, _node_ right}
*    **gte-op-expr**: {_node_ left, _node_ right}
*    **eq-op-expr**: {_node_ left, _node_ right}
*    **eqs-op-expr**: {_node_ left, _node_ right}
*    **neq-op-expr**: {_node_ left, _node_ right}
*    **neqs-op-expr**: {_node_ left, _node_ right}
*    **add-op-expr**: {_node_ left, _node_ right}
*    **sub-op-expr**: {_node_ left, _node_ right}
*    **mul-op-expr**: {_node_ left, _node_ right}
*    **div-op-expr**: {_node_ left, _node_ right}
*    **mod-op-expr**: {_node_ left, _node_ right}
*    **lsh-op-expr**: {_node_ left, _node_ right}
*    **rsh-op-expr**: {_node_ left, _node_ right}
*    **bit-and-op-expr**: {_node_ left, _node_ right}
*    **bit-or-op-expr**: {_node_ left, _node_ right}
*    **bit-xor-op-expr**: {_node_ left, _node_ right}
*    **or-op-expr**: {_node_ left, _node_ right}
*    **and-op-expr**: {_node_ left, _node_ right}
*    **instanceof-op-expr**: {_node_ left, _node_ right}
*    **in-op-expr**: {_node_ left, _node_ right}
*    **seq-op-expr**: {_node_ left, _node_ right}

### Expressions
*    **num-op-expr**: {_node_ expr}
*    **neg-op-expr**: {_node_ expr}
*    **not-op-expr**: {_node_ expr}
*    **bit-not-op-expr**: {_node_ expr}
*    **typeof-op-expr**: {_node_ left, _node_ right}
*    **void-op-expr**: {_node_ left, _node_ right}
*    **lt-op-expr**: {_node_ left, _node_ right}
*    **lte-op-expr**: {_node_ left, _node_ right}
*    **gt-op-expr**: {_node_ left, _node_ right}
*    **gte-op-expr**: {_node_ left, _node_ right}
*    **eq-op-expr**: {_node_ left, _node_ right}
*    **eqs-op-expr**: {_node_ left, _node_ right}
*    **neq-op-expr**: {_node_ left, _node_ right}
*    **neqs-op-expr**: {_node_ left, _node_ right}
*    **add-op-expr**: {_node_ left, _node_ right}
*    **sub-op-expr**: {_node_ left, _node_ right}
*    **mul-op-expr**: {_node_ left, _node_ right}
*    **div-op-expr**: {_node_ left, _node_ right}
*    **mod-op-expr**: {_node_ left, _node_ right}
*    **lsh-op-expr**: {_node_ left, _node_ right}
*    **rsh-op-expr**: {_node_ left, _node_ right}
*    **bit-and-op-expr**: {_node_ left, _node_ right}
*    **bit-or-op-expr**: {_node_ left, _node_ right}
*    **bit-xor-op-expr**: {_node_ left, _node_ right}
*    **or-op-expr**: {_node_ left, _node_ right}
*    **and-op-expr**: {_node_ left, _node_ right}
*    **instanceof-op-expr**: {_node_ left, _node_ right}
*    **in-op-expr**: {_node_ left, _node_ right}
*    **seq-op-expr**: {_node_ left, _node_ right}
*    **this-expr**: {}
*    **call-expr**: {_node_ expr, _Array<_node_>_ args}
*    **new-expr**: {_node_ constructor, _Array<_node_>_ args}
*    **if-expr**: {_node_ expr, _node_ thenExpr, _node_ elseExpr}
*    **scope-ref-expr**: {_String_ value}
*    **static-ref-expr**: {_node_ base, _String_ value}
*    **dyn-ref-expr**: {_node_ base, _node_ index}
*    **static-method-call-expr**: {_node_ base, _String_ value, _Array<_node_>_ args}
*    **dyn-method-call-expr**: {_node_ base, _node_ index, _Array<_node_>_ args}
*    **scope-delete-expr**: {_String_ value}
*    **static-delete-expr**: {_node_ base, _String_ value}
*    **dyn-delete-expr**: {_node_ base, _node_ index}
*    **scope-assign-expr**: {_String_ value, _node_ expr}
*    **static-assign-expr**: {_node_ base, _String_ value, _node_ expr}
*    **dyn-assign-expr**: {_node_ base, _node_ index, _node_ expr}
*    **scope-inc-expr**: {_Boolean_ pre, _Number_ inc, _String_ value}
*    **static-inc-expr**: {_Boolean_ pre, _Number_ inc, _node_ base, _String_ value}
*    **dyn-inc-expr**: {_Boolean_ pre, _Number_ inc, _node_ base, _node_ index}

### Statements
*    **block-stat**: {_Array<_node_>_ stats}
*    **expr-stat**: {_node_ expr}
*    **ret-stat**: {_node_ expr}
*    **if-stat**: {_node_ expr, _node_ thenStat, _node_ elseStat}
*    **while-stat**: {_node_ expr, _node_ stat}
*    **do-while-stat**: {_node_ expr, _node_ stat}
*    **for-stat**: {_node_ init, _node_ expr, _node_ step, _node_ stat}
*    **for-in-stat**: {_Boolean_ isvar, _String_ value, _node_ expr, _node_ stat}
*    **switch-stat**: {_node_ expr, _Array<_{_node_ match, _node_ stat}_>_ cases}
*    **throw-stat**: {_node_ expr}
*    **try-stat**: {_node_ tryStat, _{_String_ value, _node_ stat}_ catchBlock, _node_ finallyStat}
*    **var-stat**: {_Array<_{_String_ value, _node_ expr}_>_ vars}
*    **defn-stat**: {_node_ closure}
*    **label-stat**: {_String_ name, _node_ stat}
*    **break-stat**: {_String_ label}
*    **continue-stat**: {_String_ label}