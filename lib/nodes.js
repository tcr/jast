(function() {
  var Node, jast, x, _i, _j, _len, _len2, _ref, _ref2, _ref3;
  jast = (_ref = require('./jast'), Node = _ref.Node, _ref);
  jast.types = {};
  jast.define = function(name, args) {
    return jast.types[name] = args;
  };
  Node = jast.Node = {};
  jast.isContext = function(o) {
    return o != null ? o[0].match(/-context$/) : void 0;
  };
  jast.define("script-context", {
    stat: Node
  });
  jast.define("closure-context", {
    name: String,
    args: Array(String),
    stat: Node
  });
  jast.isLiteral = function(o) {
    return o != null ? o[0].match(/-literal$/) : void 0;
  };
  jast.define("num-literal", {
    value: Number
  });
  jast.define("str-literal", {
    value: String
  });
  jast.define("obj-literal", {
    props: Array({
      value: String,
      expr: Node
    })
  });
  jast.define("array-literal", {
    exprs: Array(Node)
  });
  jast.define("undef-literal");
  jast.define("null-literal");
  jast.define("boolean-literal", {
    value: Boolean
  });
  jast.define("func-literal", {
    closure: Node
  });
  jast.define("regex-literal", {
    expr: String,
    flags: String
  });
  jast.isOp = function(o) {
    return o != null ? o[0].match(/-op-expr$/) : void 0;
  };
  jast.isUnaryOp = function(o) {
    return jast.isOp(o) && o.length === 3;
  };
  jast.isBinaryOp = function(o) {
    return jast.isOp(o) && o.length === 4;
  };
  _ref2 = ['num', 'neg', 'not', 'bit-not', 'typeof', 'void'];
  for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
    x = _ref2[_i];
    jast.define("" + x + "-op-expr", {
      expr: Node
    });
  }
  _ref3 = ['lt', 'lte', 'gt', 'gte', 'eq', 'eqs', 'neq', 'neqs', 'add', 'sub', 'mul', 'div', 'mod', 'lsh', 'rsh', 'bit-and', 'bit-or', 'bit-xor', 'or', 'and', 'instanceof', 'in', 'typeof', 'void', 'seq'];
  for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
    x = _ref3[_j];
    jast.define("" + x + "-op-expr", {
      left: Node,
      right: Node
    });
  }
  jast.isExpr = function(o) {
    return o != null ? o[0].match(/-expr$/) : void 0;
  };
  jast.define("this-expr");
  jast.define("call-expr", {
    expr: Node,
    args: Array(Node)
  });
  jast.define("new-expr", {
    constructor: Node,
    args: Array(Node)
  });
  jast.define("if-expr", {
    expr: Node,
    thenExpr: Node,
    elseExpr: Node
  });
  jast.define("scope-ref-expr", {
    value: String
  });
  jast.define("static-ref-expr", {
    base: Node,
    value: String
  });
  jast.define("dyn-ref-expr", {
    base: Node,
    index: Node
  });
  jast.define("static-method-call-expr", {
    base: Node,
    value: String,
    args: Array(Node)
  });
  jast.define("dyn-method-call-expr", {
    base: Node,
    index: Node,
    args: Array(Node)
  });
  jast.define("scope-delete-expr", {
    value: String
  });
  jast.define("static-delete-expr", {
    base: Node,
    value: String
  });
  jast.define("dyn-delete-expr", {
    base: Node,
    index: Node
  });
  jast.define("scope-assign-expr", {
    value: String,
    expr: Node
  });
  jast.define("static-assign-expr", {
    base: Node,
    value: String,
    expr: Node
  });
  jast.define("dyn-assign-expr", {
    base: Node,
    index: Node,
    expr: Node
  });
  jast.define("scope-inc-expr", {
    pre: Boolean,
    inc: Number,
    value: String
  });
  jast.define("static-inc-expr", {
    pre: Boolean,
    inc: Number,
    base: Node,
    value: String
  });
  jast.define("dyn-inc-expr", {
    pre: Boolean,
    inc: Number,
    base: Node,
    index: Node
  });
  jast.isStat = function(o) {
    return o != null ? o[0].match(/-stat$/) : void 0;
  };
  jast.define("block-stat", {
    stats: Array(Node)
  });
  jast.define("expr-stat", {
    expr: Node
  });
  jast.define("ret-stat", {
    expr: Node
  });
  jast.define("if-stat", {
    expr: Node,
    thenStat: Node,
    elseStat: Node
  });
  jast.define("while-stat", {
    expr: Node,
    stat: Node
  });
  jast.define("do-while-stat", {
    expr: Node,
    stat: Node
  });
  jast.define("for-stat", {
    init: Node,
    expr: Node,
    step: Node,
    stat: Node
  });
  jast.define("for-in-stat", {
    isvar: Boolean,
    value: String,
    expr: Node,
    stat: Node
  });
  jast.define("switch-stat", {
    expr: Node,
    cases: Array({
      match: Node,
      stat: Node
    })
  });
  jast.define("throw-stat", {
    expr: Node
  });
  jast.define("try-stat", {
    tryStat: Node,
    catchBlock: {
      value: String,
      stat: Node
    },
    finallyStat: Node
  });
  jast.define("var-stat", {
    vars: Array({
      value: String,
      expr: Node
    })
  });
  jast.define("defn-stat", {
    closure: Node
  });
  jast.define("label-stat", {
    name: String,
    stat: Node
  });
  jast.define("break-stat", {
    label: String
  });
  jast.define("continue-stat", {
    label: String
  });
}).call(this);
