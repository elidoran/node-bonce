{join}                  = require 'path'
processArgs             = require './args'
readOptionsFile         = require './options-file'
readOrGenerateInputFile = require './input-file'
showOpInfo              = require './printout'

module.exports = (options) ->

  op = # start with some default info
    options: basedir:'.', debug:false
    quiet: false

  info = # defined when a module name is specified, true, or false when `not`
    include: undefined
    exin: [] # hold excluded/included module refs

  # look at process's args and generate op and info values
  processArgs op, info, options

  # read the options file, if it exists, and put its info into `op`
  readOptionsFile op, info

  # prepare input for browserify by reading an input file or generating one
  readOrGenerateInputFile op, info

  # use the default if none specified
  op.outputFile ?= join op.options.basedir, 'package.browserified.js'

  # TODO: what should this be, really?
  op.mapPath ?= op.outputFile

  # show the op and info data
  showOpInfo op, info

  return op
