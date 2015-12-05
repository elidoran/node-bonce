fs = require 'fs'

# used to:
#  1. check for basedir in args
#  2. filter directories from all files in node_modules
module.exports = (string) ->
  try
    return fs.statSync(string).isDirectory()
  catch error
    return false
