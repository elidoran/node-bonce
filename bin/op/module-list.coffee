isDir  = require './isDir'
{join} = require 'path'
fs     = require 'fs'

module.exports = (basedir) ->

  nodeModulesDir = join basedir, 'node_modules'

  # get the all file names in node_modules
  moduleNames = fs.readdirSync nodeModulesDir

  # get only the directories
  moduleNames = (name for name in moduleNames when isDir join nodeModulesDir, name)

  return moduleNames
