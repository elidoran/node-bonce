stripComments = require 'strip-json-comments'
fs = require 'fs'
{join} = require 'path'

module.exports = (op, info) ->

  # if no options file was specified then check the default location
  unless info.optionsFile?
    # generate the default location based on the basedir
    optionsFile = join op.options.basedir, 'node_modules', 'options.json'
    # if it does *not* exist then clear the variable of the default value
    if fs.existsSync optionsFile then info.optionsFile = optionsFile

  # if there's an options file, then read it and put the options into op
  if info.optionsFile?
    # read the json file, strip any comments
    fileContent = fs.readFileSync info.optionsFile, 'utf8'
    options = JSON.parse stripComments fileContent, whitespace:false

    # pull these out of options and into `op` first so they're not in `op.options`
    # TODO: if they do 'not some-module' do we add that to ignores? excludes? neither?
    for name in [ 'transforms', 'excludes', 'externals', 'ignores']
      if options[name]?
        op[name] = options[name]
        delete options[name]

    # TODO: module includes/excludes?
    # TODO: `requires` section for includes? allow specifying the name (expose?)

    # now override the default options with these options
    # except debug which must be true, and basedir if specified by an arg...
    rememberedBasedir = op.options.basedir

    # copy over properties
    op.options[key] = value for key,value of options

    # restore debug and basedir...
    op.options.debug = true
    if rememberedBasedir isnt '.' then op.options.basedir = rememberedBasedir

  return
