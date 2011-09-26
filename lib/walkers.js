(function() {
  var jast, set;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  jast = require('./jast');
  jast.walk = function(n, f) {
    var check;
    if (f == null) {
      f = jast.walk;
    }
    check = __bind(function(type, value) {
      var prop, ptype, pvalue, _ref, _ref2;
      if (type === jast.Node) {
        return f(value);
      } else if ((type != null ? type.constructor : void 0) === Array) {
        return (_ref = []).concat.apply(_ref, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = value.length; _i < _len; _i++) {
            pvalue = value[_i];
            _results.push(check(type[0], pvalue));
          }
          return _results;
        })());
      } else if (typeof type === 'object') {
        return (_ref2 = []).concat.apply(_ref2, (function() {
          var _results;
          _results = [];
          for (prop in type) {
            ptype = type[prop];
            _results.push(check(ptype, value[prop]));
          }
          return _results;
        })());
      } else {
        return [];
      }
    }, this);
    return check(jast.types[n.type], n);
  };
  jast.strings = function(n, f) {
    if (f == null) {
      f = jast.strings;
    }
    if (n.type === "str-literal") {
      return [n.value];
    }
    return jast.walk(n, f);
  };
  jast.numbers = function(n, f) {
    if (f == null) {
      f = jast.numbers;
    }
    if (n.type === "num-literal") {
      return [n.value];
    }
    return jast.walk(n, f);
  };
  jast.regexps = function(n, f) {
    if (f == null) {
      f = jast.regexps;
    }
    if (n.type === "regexp-literal") {
      return [[n.expr, n.flags]];
    }
    return jast.walk(n, f);
  };
  jast.contexts = function(ctx, f) {
    if (f == null) {
      f = jast.contexts;
    }
    if (jast.isContext(ctx)) {
      return [ctx].concat(f(ctx.stat));
    }
    return jast.walk(ctx, f);
  };
  jast.vars = function(n, f) {
    var k, v, _ref;
    if (f == null) {
      f = jast.vars;
    }
    switch (n.type) {
      case "closure-context":
        return (n.name != null ? [n.name] : []).concat(n.args, f(n.stat));
      case "var-stat":
        return (_ref = (function() {
          var _i, _len, _ref2, _ref3, _results;
          _ref2 = n.vars;
          _results = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            _ref3 = _ref2[_i], k = _ref3[0], v = _ref3[1];
            _results.push(k);
          }
          return _results;
        })()).concat.apply(_ref, (function() {
          var _i, _len, _ref, _ref2, _results;
          _ref = n.vars;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            _ref2 = _ref[_i], k = _ref2[0], v = _ref2[1];
            if (v) {
              _results.push(f(v));
            }
          }
          return _results;
        })());
      case "for-in-stat":
        return (n.isvar ? [n.value] : []).concat(f(n.stat));
      case "try-stat":
        return f(n.tryStat).concat((n.catchBlock ? [n.catchBlock.value].concat(f(n.catchBlock.stat)) : []), (n.finallyStat ? f(x) : []));
      case "scope-ref-expr":
        if (n.value === "arguments") {
          return ["arguments"];
        } else {
          return [];
        }
      case "defn-stat":
        if (n.closure.name != null) {
          return [n.closure.name];
        } else {
          return [];
        }
      default:
        return jast.walk(n, f);
    }
  };
  jast.localVars = function(n, f) {
    var _ref;
    if (f == null) {
      f = jast.localVars;
    }
    if ((_ref = n.type) === "script-context" || _ref === "closure-context") {
      return [];
    }
    return jast.vars(n, f);
  };
  jast.usesArguments = function(closure) {
    return __indexOf.call(jast.localVars(closure.stat), "arguments") >= 0;
  };
  jast.localRefs = function(n, f) {
    if (f == null) {
      f = jast.localRefs;
    }
    switch (n.type) {
      case "script-context":
      case "closure-context":
        return [];
      case "scope-ref-expr":
      case "scope-assign-expr":
      case "scope-delete-expr":
        return [value];
      default:
        return jast.walk(n, f);
    }
  };
  set = function(a) {
    var k, o, r, _, _i, _len;
    o = {};
    r = [];
    for (_i = 0, _len = a.length; _i < _len; _i++) {
      k = a[_i];
      o[k] = true;
    }
    for (k in o) {
      _ = o[k];
      r.push(k);
    }
    return r;
  };
  jast.localUndefinedRefs = function(ctx) {
    var k, refs, vars;
    refs = jast.localRefs(ctx.stat);
    vars = jast.localVars(ctx.stat);
    return set((function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = refs.length; _i < _len; _i++) {
        k = refs[_i];
        if (__indexOf.call(vars, k) < 0) {
          _results.push(k);
        }
      }
      return _results;
    })());
  };
  jast.undefinedRefs = function(o) {
    var ctx, _ref;
    return set((_ref = []).concat.apply(_ref, (function() {
      var _i, _len, _ref, _results;
      _ref = jast.contexts(o);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ctx = _ref[_i];
        _results.push(jast.localUndefinedRefs(ctx));
      }
      return _results;
    })()));
  };
}).call(this);
