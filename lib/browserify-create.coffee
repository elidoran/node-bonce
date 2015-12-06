module.exports = (op) ->

  # change from file path to a readable stream for Browserify
  if 'string' is typeof op.inputFile
    fs = require 'fs' # only get this if we need to use it here
    op.inputFile = fs.createReadStream op.inputFile

  # create a Browserify instance with the input file and options
  browserify = require('browserify') op.inputFile, op.options

  # options file has arrays for these.
  # each element is either a string or an object with props: name and options
  # some should have a basedir set for proper resolution, so, we'll set it in there
  # if it doesn't exist already.
  basedirObject = basedir:op.options.basedir
  for prop in ['require', 'ignore', 'exclude', 'external', 'transform']
    # if it has the array and there is at least one element
    if op?[prop]?.length > 0
      for each in op[prop]
        # if it's an array of strings then add each element
        if 'string' is typeof each then browserify[prop] each, basedirObject

        else # it's an object so get its name and options properties
          # set our object in there if there's no options object
          each.options ?= basedirObject
          # if they provided options, ensure there's a basedir property
          each.options.basedir ?= basedirObject.basedir
          browserify[prop] each.name, each.options

  # get the stream which will activate the operation (when we pipe it)
  browserify.bundle()
