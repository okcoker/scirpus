
# base on Mozilla Parsing API
# https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API

exports.transform = (code) ->
  Program code

# tools

isString = (x) ->
  (typeof x) is "string"

isToken = (code) ->
  hasText = isString code.text
  hasLine = hasLineInfo code
  hasText and hasLine

isExpression = (code) ->
  not (isToken code)

hasLineInfo = (code) ->
  hasStart = code.start? and code.start.x?
  hasEnd = code.end? and code.end.x?
  hasStart and hasEnd

guessNumber = (x) ->
  guess = Number x
  if isNaN guess then x else guess

# Grammers for Cirru

registry = {}

translate = (code) ->
  name = code[0].text
  if name? and registry[name]?
    registry[name] code
  else
    null

# Node objects

copyLoc = (code) ->
  if isToken code
    SourceLocation code
  else
    null

SourceLocation = (code) ->
  source: code.text
  start: Position code.start
  end: Position code.end

Position = (pos) ->
  line: pos.y + 1
  column: pos.x

# Programs

Program = (code) ->
  type: "Program"
  body: code.map (x) ->
    translate x # Statement

# Functions

# Statements

registry.empty = (code) ->
  type: "EmptyStatement"

registry.block = (code) ->
  type: "BlockStatement"
  body: code.map (x) ->
    translate x # Statement

registry.expression = (code) ->
  type: "ExpressionStatement"
  expression: translate code[1] # Expression

registry.if = (code) ->
  type: "IfStatement"
  test: translate code[1] # Expression
  consequent: translate code[2] # Statement
  alternate: translate code[3] # Statement

registry.label = (code) ->
  type: "LabeledStatement"
  label: translate code[1] # Identifier
  body: translate code[2] # Statement

registry.break = (code) ->
  type: "BreakStatement"
  label: translate code[1] # Identifier

registry.continute = (code) ->
  type: "ContinuteStatement"
  label: translate code[1] # Identifier

registry.with = (code) ->
  type: "WithStatement"
  object: translate code[1] # Expression
  body: translate code[2] # Statement

registry.switch = (code) ->
  type: "SwitchStatement"
  lexical: yes
  discriminant: translate code[1] # Expression
  cases: code[2].map (x) ->
    translate x # SwitchCase

registry.return = (code) ->
  type: "ReturnStatement"
  argument: translate code[1] # Expression

registry.throw = (code) ->
  type: "ThrowStatement"
  argument: translate code[1] # Expression

registry.try = (code) ->
  type: "TryStatement"
  block: translate code[1]
  handler: translate code[2]
  guardedHandlers: code[3].map (x) ->
    translate x # CatchClause
  finalizer: translate code[4] # BlockStatement

registry.while = (code) ->
  type: "WhileStatement"
  test: translate code[1] # Expression
  body: translate code[2] # Statement

registry.do = (code) ->
  type: "DoWhileStatement"
  body: translate code[1] # Statement
  test: translate code[2] # Expression

registry.for = (code) ->
  type: "ForStatement"
  init: translate code[1] # VariableDeclaration | Expression
  test: translate code[2] # Expression
  upadte: translate code[3] # Expression
  body: translate code[4] # Statement

registry.each = (code) ->
  type: "ForInStatement"
  left: translate code[1] # VariableDeclaration |  Expression
  right: translate code[2] # Expression
  body: translate code[3] # Statement
  each: no

registry.of = (code) ->
  type: "ForOfStatement"
  left: translate code[1] # VariableDeclaration |  Expression
  right: translate code[2] # Expression
  body: translate code[3] # Statement

# drop let for it's SpiderMonkey-specific

registry.debugger = (code) ->
  type: "DebuggerStatement"

# Declarations

registry.func = (code) ->
  type: "FunctionDeclaration"
  id: translate code[0] # Identifier
  params: code[1].map (x) ->
    translate x # Pattern
  defaults: [] # Expression.. but what is this?
  rest: null # still, what's this?
  body: translate x # BlockStatement | Expression
  generator: no
  expression: no

registry.var = (code) ->
  type: "VariableDeclaration"
  declaration: code[1].map (x) ->
    translate x # VariableDeclarator
  kind: "var" # drop let and const

registry.decorator = (code) ->
  type: "VariableDeclarator"
  id: translate code[1] # Pattern
  init: translate code[2] # Expression

# Expressions

registry.this = (code) ->
  type: "ThisExpression"

# Patterns

# Clauses

# Miscellaneous

registry.identifier = (code) ->
  loc: copyLoc code[1]
  type: "Identifier"
  name: code[1].text

registry.literal = (code) ->
  loc: copyLoc code[1]
  type: "Literal"
  raw: code[1].text
  value: guessNumber code[1].text