handleError = (error, options) ->
  console.log '!! Failed to complete `bonce` operation'
  console.log '  ', error.toString()
  if options?.done? then options.done error
  else process.exit 1 # TODO: Lookup the exit number to use

module.exports = (op, options) ->

  # if an error occurred somewhere along the way then report it and return
  if op.error? then return handleError op.error, options

  # if we make it this far, we'll need these
  strung = require('strung')
  fs = require 'fs'

  # create a new Browserify with the input file (array) and browserify options
  stream = require('./browserify-create') op

  # handle results, success and error. Count pending tasks.
  pending = 1
  resultsHandler = (error) ->
    if error? then handleError error, options
    else
      pending--
      if pending < 1
        unless op.quiet then console.log 'bonce Successful.'
        options?.done?()

  # create a stream to collect the source
  source = strung()

  # hold in array so we can add the source map stuff if we need to
  errorProducers = [ stream, source ]

  # when it's all done write out the source
  source.on 'finish', ->
    fs.writeFile op.outputFile, source.string, resultsHandler

  # if generating a source map, then, create the extra stuff we need
  if op.map
    sourceMap = strung()
    sourceMapExtractingStream = require('exorcist-stream') sourceMap, op.mapPath
    errorProducers.push sourceMapExtractingStream, sourceMap

    # add another finisher to write out the source map file
    # add to the pending count so the results handler knows we have more to do
    source.on 'finish', ->
      pending++
      fs.writeFile op.outputFile + '.map', sourceMap.string, resultsHandler

    # pipe to the source map extractor and put it in the same var used below
    stream = stream.pipe sourceMapExtractingStream

  # add error handler to all these (now that the source map ones were added)
  each.on 'error', resultsHandler for each in errorProducers

  # pipe to the final stream to get the source
  stream.pipe source

  return
