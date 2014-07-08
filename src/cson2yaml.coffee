xcson = require 'xcson'
type = require 'typeof'

indentBy = '  '
indents = (n) -> Array(n).join indentBy

stringify = (data) ->
  indentLevel = 0

  handlers =

    array: (arr) ->
      return '[]' if arr.length is 0

      output = ""

      indentLevel++

      for a in arr
        handler = handlers[type(a)]
        # throw new Error("what the crap: " + type(y))  unless handler
        output += "\n" + indents(indentLevel) + "- " + handler(a)

      indentLevel--

      output

    boolean: (bool) -> if bool then "true" else "false"

    function: (func) -> throw new Error "Unexpected function #{func}"

    null: -> "null"

    number: (n) -> n

    object: (obj) ->

      output = ""
      indentLevel++

      for key, val of obj
        handler = handlers[type(val)]
        continue if type(val) is "undefined" or not handler
        output += "\n" + indents(indentLevel) + "#{key}: #{handler(val)}"

      indentLevel--

      return output or '{}'

    string: (str) ->
      return "\"#{str}\"" if str.match /^(true|false|undefined|null)$/

      safestr = JSON.stringify(str).replace /^"|"$/g, ""

      # This is a multiline string
      if safestr.match /\\n/
        return "|\n" + indents(indentLevel+1) + safestr.replace(/(\\n|\\r)/g, "\n" +indents(indentLevel+1))

      safestr

    undefined: -> "null"

  return "---" + handlers[type(data)](data) + "\n"

module.exports = cson2yaml = (file) ->
  stringify new xcson(file).toObject()

