isDir  = require './isDir'

module.exports = (op, info, options) ->

  # ignore the first arg, it's the runner or the script
  args = options?.args ? process.argv[1..]

  # explicitly ignore first args which are an executable or the command script
  # Note: for running it during dev as: coffee bin/bonce.js
  while args?[0]? and (args[0] in ['node', 'coffee'] or args[0][-8..] is 'bonce.js')
    args.shift()

  for arg in args # look at each arg and decide what to do with it

    # stop when we see --
    if '--' is arg then break
    
    # if it's an existing directory then it's our basedir
    else if isDir arg then op.options.basedir = arg

    # if it's a file ending with 'browserify.js' then it's the input file
    else if arg[-13...] is 'browserify.js'
      info.inputFileName = arg # remember this for outputting to the console
      op.inputFile = fs.createReadStream arg

    # if it's a file ending with '.js' then it's the output file
    else if arg[-3...] is '.js' then op.outputFile = arg

    # if it's a file ending with '.json' then it's the options file
    else if arg[-5...] is '.json' then info.optionsFile = arg

    # if it's 'not' then we are doing excludes
    else if arg is 'not' then info.include = false

    else if arg in ['-q', '--quiet'] then op.quiet = true

    else if arg in ['-g', '--showgen'] then op.showGeneratedInput = true

    # else it's a module name for either include/exclude
    else
      info.include ?= true # optional because if we saw `not` then it's false already
      # split off the variable name from the end, if it's there
      split = arg.split '#'
      # if there are slashes (a path into the module) get the first part as the name
      moduleName = split[0].split(/\\|\//)[0]
      # store in `exin` to use when generating input, and outputting info to console
      info.exin[moduleName] = path:split[0], varName:split?[1]

  return
