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

module.exports = (op, info) ->

  unless op.inputFile? # then check the default location
    # generate the default location based on the basedir
    inputFileName = join op.options.basedir, 'node_modules', 'browserify.js'

    # if it exists then put it in the op
    if fs.existsSync inputFileName
      info.inputFileName = op.inputFile = inputFileName

  unless op.inputFile? # generate input when not specified
    moduleNames = require('./module-list') op.options.basedir

    # start with empty input
    input = ''

    # we include all modules unless some were specified for include/exclude
    unless info.include? then all = true

    # let's make sure we find all the modules we are *supposed to* find
    # we only care when include exists and is true
    # when it doesn't exist then the user didn't specify any
    # when it's false only exclusions were specified
    find = {}
    # when include is true add each specified module name
    # use an object so we can delete the key when we find it (easier than array removal)
    # if `include` isn't true then we don't add any and `find` remains empty
    if info.include then find[name] = false for name of info.exin

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

  # else there is an inputFile, so, what about the exin values?
  # we could add includes to the options.require array
  # we could add excludes to excludes array, or ignores array...
  # else

  return
