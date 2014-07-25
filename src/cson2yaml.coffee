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
        output += "\n" + indents(indentLevel) + "- " + handler(a, 1)

      indentLevel--

      output

    boolean: (bool) -> if bool then "true" else "false"

    function: (func) -> throw new Error "Unexpected function #{func}"

    null: -> "null"

    number: (n) -> n

    object: (obj, extratab=0) ->

      indentLevel++

      # If we need an extra tab, we're probably in an array layout:
      # - foo:
      indentThis = "\n" + indents(indentLevel+extratab)

      output = (for key, val of obj
        handler = handlers[type(val)]
        continue if type(val) is "undefined" or not handler
        "#{key}: #{handler(val)}"
      ).join(indentThis)

      indentLevel--

      return "{}" unless output

      # If this was an array style layout, don't add a newline+tab to the first
      # line
      # - foo:
      # NOT
      # -
      # foo:
      leadIndent = if extratab then "" else indentThis

      return leadIndent + output

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

  if typeof file is 'object'
    stringify file
  else
    stringify new xcson(file).toObject()
