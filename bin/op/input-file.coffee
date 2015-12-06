{join} = require 'path'
fs = require 'fs'

# generate the variable name for a module when one isn't specified.
# removes non-alphanumeric characters and capitalizes the first letter after each one
# example: upper-case becomes upperCase
varNameFor = (moduleName) ->
  split = moduleName.split /[^\w\d]+/
  varName = split[0]
  varName += each[0].toUpperCase() + each[1..] for each in split[1..]
  return varName

convertExin = (exinArray) ->
  # process the `exin` array and convert refs to objects with: name, path, varName
  # replace it with an object so they can be ref'd by name
  exin = {}
  for each in exinArray
    # split off the variable name from the end, if it's there
    split = each.split '#'

    # if there are slashes (a path into the module) get the first part as the name
    moduleName = split[0].split(/\\|\//)[0]

    # store in `exin` to use when generating input, and outputting info to console
    exin[moduleName] =
      # path is what's before the '#', or, the whole thing when there isn't one
      path:split[0]
      # varName is what's after the '#', if it exists
      varName:split?[1]

  return exin

checkDefaultLocation = (op, info) ->
  # generate the default location based on the basedir
  inputFile = join op.options.basedir, 'node_modules', 'browserify.js'

  # if it exists then put it in the op
  if fs.existsSync inputFile then info.inputFileName = op.inputFile = inputFile

  return

generateInput = (op, info) ->

  moduleNames = require('./module-list') op.options.basedir

  # start with empty input
  input = ''

  # we include all modules unless some were specified for include/exclude
  unless info.include? then all = true

  # replace the array with the object
  #  1. so we can reference them by name
  #  2. convert string into: module name, module path, and varName
  info.exin = convertExin info.exin

  # let's make sure we find all the modules we are *supposed to* find
  # we only care when include exists and is true
  # when it doesn't exist then the user didn't specify any
  # when it's false only exclusions were specified
  find = {}
  # when include is true add each specified module name
  # use an object so we can delete the key when we find it (easier than array removal)
  # if `include` isn't true then we don't add any and `find` remains empty
  if info.include then find[each.name] = false for each in info.exin

  # let's keep track of all the modules we exclude because:
  #  1. we're in `include` mode and they aren't in the explicit inclusion list
  #  2. we're in `exclude` mode and they are in the explicit exclusion list
  skipped = []

  for name in moduleNames
    # if we are looking for this module then mark it found by deleting it
    delete find[name]

    # skip this one unless we are including all modules,
    # or, this one was specified as an include,
    # or, this one was *not* specified as an exclude
    unless all or
      (info.include and info.exin[name]?) or
      not (info.include or info.exin[name]?)
        skipped.push name
        continue

    # either use the specified name or generate one
    varName = info.exin?[name]?.varName ? varNameFor name

    # either use the specified path or the module name
    moduleNameOrPath = info.exin?[name]?.path ? name

    # add a line to input which requires it into the variable
    input += "#{varName} = require('#{moduleNameOrPath}');\n"

  if op.showGeneratedInput
    console.log '\n  Generated Input\n-------------------------------------------\n'
    console.log input
    console.log '-------------------------------------------'

  # check if we found all the modules we were supposed to
  if Object.keys(find).length > 0
    error = 'Missing modules:'
    error += '\n    ' + name for name of find
    op.error = error

  # create only when there's input
  else if input.length > 0
    # create a strung with the input in it and put it in the array for Browserify
    op.inputFile = require('strung') input

  # we must have excluded all the modules found
  else if skipped.length is moduleNames.length
    op.error = 'Empty input because all available modules were excluded.'

  else
    op.error = 'Empty input'


ensureFileExists = (op, info) ->
  # there is an inputFile specified, so, let's make sure it exists
  # check if the file exists as-is
  unless fs.existsSync op.inputFile
    # if not as-is, check for it in 'node_modules'
    inputFileName = join op.options.basedir, 'node_modules', op.inputFile
    if fs.existsSync inputFileName
      # change input file to the one we found in node_modules
      op.inputFile = info.inputFileName = inputFileName
    else
      # work will halt after options are shown and this error will be reported
      op.error = 'Unable to locate input file as specified or in node_modules'

  return

module.exports = (op, info) ->
  
  unless op.inputFile? then checkDefaultLocation op, info

  unless op.inputFile? then generateInput op, info

  else ensureFileExists op, info

  return
