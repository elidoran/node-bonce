handleError = (error, options) ->
  console.log '!! Failed to complete `bonce` operation'
  console.log '  ', error.toString()
  if options?.done? then options.done error
  else process.exit 1 # TODO: Lookup the exit number to use

module.exports = (op, options) ->

  if op.error? then return handleError op.error, options

  # create a new Browserify with the input file (array) and browserify options
  browserify = require('./browserify-create') op

  # create streams to collect the source and source map
  source    = (strung = require('strung'))()
  sourceMap = strung()
  sourceMapExtractingStream = require('exorcist-stream') sourceMap, op.mapPath

  # handle results, success and error. Count to 2 for two async operations
  successCount = 0
  resultsHandler = (error) ->
    if error? then handleError error, options
    else
      successCount++
      if successCount > 1
        unless op.quiet then console.log 'bonce Successful.'
        options?.done?()

  # add error handler to all these
  for each in [ browserify, sourceMapExtractingStream, sourceMap, source]
    each.on 'error', resultsHandler

  # when it's all done write out the source and source map file
  source.on 'finish', ->
    fs = require 'fs'
    fs.writeFile op.outputFile, source.string, resultsHandler

    # TODO: do we make a map file for the package? Does Meteor accept it?
    fs.writeFile op.outputFile + '.map', sourceMap.string, resultsHandler

  # finally, perform the browserifying and send the results thru the streams
  browserify.pipe(sourceMapExtractingStream).pipe(source)

  return
