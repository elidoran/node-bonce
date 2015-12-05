module.exports = (op) ->

  # create a Browserify instance with the input file and options
  browserify = require('browserify') op.inputFile, op.options

  # TODO: apply ignore/exclude/external options

  # apply transforms from `op`
  for transform in op.transforms
    browserify.transform transform.name, transform.options

  # get the stream which will activate the operation (when we pipe it)
  browserify.bundle()
