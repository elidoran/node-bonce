module.exports = (options) ->

  # read cli options and options file and produce an `op`
  op = require('./op') options?.create

  # get `bonce` function and run it with `op`
  require('../lib') op, options?.bonce
