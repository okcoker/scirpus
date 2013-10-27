// Generated by CoffeeScript 1.6.3
var copy_loc, expand, expand_assignment_expression, expand_call_expression, expand_identifier, expand_literal, expand_member_expression, grammers, is_exp, is_number, is_string, is_token, stringify, transform, type,
  __slice = [].slice;

type = function(x) {
  var raw;
  raw = Object.prototype.toString.call(x);
  return raw.slice(8, -1).toLowerCase();
};

is_number = function(x) {
  return x >= 0 || x < 0;
};

is_string = function(x) {
  return (type(x)) === "string";
};

stringify = function(x) {
  return JSON.stringify(x);
};

copy_loc = function(word) {
  if ((word.start != null) && (word.end != null)) {
    return {
      start: {
        line: word.start.y,
        column: word.start.x
      },
      end: {
        line: word.end.y,
        column: word.end.x
      }
    };
  } else {
    return null;
  }
};

is_token = function(x) {
  return ((type(x)) === "object") && (is_string(x.text));
};

is_exp = function(x) {
  return (type(x)) === "array";
};

grammers = {
  ">": function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  },
  "if": function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  },
  ":": function(args) {
    var left, right;
    left = expand_identifier(args[0]);
    right = expand(args[1]);
    console.log(args[1], right, args);
    return expand_assignment_expression(left, "=", right);
  },
  ".": function(args) {
    var object, property;
    object = expand(args[0]);
    property = expand_identifier(args[1]);
    return expand_member_expression(object, property);
  }
};

expand_literal = function(x) {
  var guess;
  guess = Number(x.text);
  console.log("guess", guess, x);
  if (is_number(guess)) {
    return {
      type: "Literal",
      value: guess,
      raw: x.text,
      loc: copy_loc(x)
    };
  } else {
    return {
      type: "Literal",
      raw: x.text,
      loc: copy_loc(x)
    };
  }
};

expand_identifier = function(word) {
  console.log("Identifier word", word);
  return {
    type: "Identifier",
    name: word.text,
    loc: copy_loc(word)
  };
};

expand_assignment_expression = function(left, operator, right) {
  return {
    type: "AssignmentExpression",
    operator: operator,
    left: left,
    right: right
  };
};

expand_call_expression = function(callee, args) {
  return {
    type: "CallExpression",
    callee: callee,
    "arguments": args
  };
};

expand_member_expression = function(object, property) {
  return {
    type: "MemberExpression",
    object: object,
    property: property,
    computed: false
  };
};

expand = function(exp) {
  var args, callee, func;
  if (is_token(exp)) {
    return expand_literal(exp);
  } else if (is_exp(exp)) {
    func = exp[0];
    if (is_token(func)) {
      if (grammers[func.text] != null) {
        return grammers[func.text](exp.slice(1));
      } else {
        throw new Error("" + (stringify(func.text)) + " not implemented");
      }
    } else if (is_exp(func)) {
      callee = expand(func);
      args = exp.slice(1).map(expand);
      return expand_call_expression(callee, args);
    } else {
      throw new Error("" + (stringify(func)) + " not recognized");
    }
  }
};

transform = function(tree) {
  return {
    type: "Program",
    body: tree.map(function(exp) {
      return {
        type: "ExpressionStatement",
        expression: expand(exp)
      };
    })
  };
};

exports.transform = transform;

/*
//@ sourceMappingURL=scirpus.map
*/