(function() {
  var set;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
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
  exports.populate = function(jast) {
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
      var x, _ref;
      if (f == null) {
        f = jast.contexts;
      }
      if (jast.isContext(ctx)) {
        return (_ref = [ctx]).concat.apply(_ref, (function() {
          var _i, _len, _ref, _results;
          _ref = ctx.stats;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            _results.push(f(x));
          }
          return _results;
        })());
      }
      return jast.walk(ctx, f);
    };
    jast.vars = function(n, f) {
      var v, x, _ref, _ref2;
      if (f == null) {
        f = jast.vars;
      }
      switch (n.type) {
        case "closure-context":
          return (_ref = (n.name != null ? [n.name] : [])).concat.apply(_ref, [n.args].concat(__slice.call((function() {
            var _i, _len, _ref, _results;
            _ref = n.stats;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              x = _ref[_i];
              _results.push(f(x));
            }
            return _results;
          })())));
        case "var-stat":
          return (_ref2 = (function() {
            var _i, _len, _ref3, _results;
            _ref3 = n.vars;
            _results = [];
            for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
              v = _ref3[_i];
              _results.push(v.value);
            }
            return _results;
          })()).concat.apply(_ref2, (function() {
            var _i, _len, _ref2, _results;
            _ref2 = n.vars;
            _results = [];
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              v = _ref2[_i];
              if (v.expr) {
                _results.push(f(v.expr));
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
    jast.localVars = function(ctx) {
      var check, stat, _ref;
      check = function(n) {
        var _ref;
        if ((_ref = n.type) === "script-context" || _ref === "closure-context") {
          return [];
        }
        return jast.vars(n, check);
      };
      return set((_ref = []).concat.apply(_ref, (function() {
        var _i, _len, _ref, _results;
        _ref = ctx.stats;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          stat = _ref[_i];
          _results.push(check(stat));
        }
        return _results;
      })()));
    };
    jast.usesArguments = function(closure) {
      var x, _ref;
      return __indexOf.call((_ref = []).concat.apply(_ref, (function() {
        var _i, _len, _ref, _results;
        _ref = closure.stats;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          _results.push(jast.localVars(x));
        }
        return _results;
      })()), "arguments") >= 0;
    };
    jast.localRefs = function(ctx) {
      var check, stat, _ref;
      check = function(n) {
        switch (n.type) {
          case "script-context":
          case "closure-context":
            return [];
          case "scope-ref-expr":
          case "scope-assign-expr":
          case "scope-delete-expr":
            return [n.value];
          default:
            return jast.walk(n, check);
        }
      };
      return set((_ref = []).concat.apply(_ref, (function() {
        var _i, _len, _ref, _results;
        _ref = ctx.stats;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          stat = _ref[_i];
          _results.push(check(stat));
        }
        return _results;
      })()));
    };
    jast.localUndefinedRefs = function(ctx) {
      var k, refs, vars;
      refs = jast.localRefs(ctx);
      vars = jast.localVars(ctx);
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
    return jast.undefinedRefs = function(n) {
      var ctx, _ref;
      return set((_ref = []).concat.apply(_ref, (function() {
        var _i, _len, _ref, _results;
        _ref = jast.contexts(n);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ctx = _ref[_i];
          _results.push(jast.localUndefinedRefs(ctx));
        }
        return _results;
      })()));
    };
  };
}).call(this);
