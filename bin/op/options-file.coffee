stripComments = require 'strip-json-comments'
fs = require 'fs'
{join} = require 'path'

module.exports = (op, info) ->

  # if no options file was specified then check the default location
  unless info.optionsFile?
    # generate the default location based on the basedir
    optionsFile = join op.options.basedir, 'node_modules', 'options.json'
    # if it exists then set the value
    if fs.existsSync optionsFile then info.optionsFile = optionsFile

  # if there's an options file, then read it and put the options into op
  if info.optionsFile?

    # check if the file exists
    unless fs.existsSync info.optionsFile
      # check for it in 'node_modules'
      filePath = join op.options.basedir, 'node_modules', info.optionsFile
      unless fs.existsSync filePath
        # work will halt after options are shown and this error will be reported
        op.error = 'Unable to locate options file as specified or in node_modules'
        return
      else
        # change file to the one we found in node_modules
        info.optionsFile = filePath

    # read the json file, strip any comments
    fileContent = fs.readFileSync info.optionsFile, 'utf8'
    options = JSON.parse stripComments fileContent, whitespace:false

    # now override the default options with these options
    # except debug which must be true, and basedir if specified by an arg...
    rememberedBasedir = op.options.basedir
    rememberedDebug   = op.options.debug

    if options.browserify?
      # pull these out of options and into `op` first so they're not in `op.options`
      # because we're going to handle them explicityly instead of passing on to
      # the Browserify instance
      for name in [ 'require', 'transform', 'exclude', 'external', 'ignore']
        if options?.browserify?[name]?
          op[name] = options.browserify[name]
          delete options.browserify[name]

      # copy over browserify properties
      op.options[key] = value for key,value of options.browserify

    # copy over bonce properties
    if options?.bonce?
      op.options.basedir = options.bonce.basedir if options.bonce.basedir?
      op.inputFile  = options.bonce.inputFile if options.bonce.inputFile?
      op.outputFile = options.bonce.outputFile if options.bonce.outputFile?

      # set the include mode
      if options.bonce.include? then info.include = true
      else if options.bonce.exclude? then info.include = false

      # copy values into `exin`
      if options.bonce.include? or options.bonce.exclude?
        info.exin.push each for each in (options.bonce.include ? options.bonce.exclude)

    # restore debug and basedir...
    # if debug was changed to true by cli args
    if rememberedDebug then op.options.debug = true
    # and if basedir was changed from the default '.' by cli args
    if rememberedBasedir isnt '.' then op.options.basedir = rememberedBasedir

  return
