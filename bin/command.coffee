module.exports = (options) ->

  # ouptput the version from the package.json file
  if '-v' in process.argv or '--version' in process.argv
    pkg = require '../package.json'
    console.log "bonce v#{pkg.version}"

  else
    # read cli options and options file and produce an `op`
    op = require('./op') options?.create

    # if `dryrun` is set then dont do the rest.
    unless op.dryrun
      # get `bonce` function and run it with `op`
      require('../lib') op, options?.bonce
