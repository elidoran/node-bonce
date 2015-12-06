isDir  = require './isDir'

commands = # some static value args
  # quiet means we won't write out options and results to the console
  '--quiet' : (op) -> op.quiet = true

  # showgen means write out the generated input file, if there is one
  '--showgen': (op) -> op.showGeneratedInput = true

  # dryrun means we don't do the browserifying, but, we output the options
  # and the generated file (if showgen is also set).
  '--dryrun': (op) -> op.dryrun = true

  # output the generated source map
  '--map': (op) -> op.map = true ; op.options.debug = true

  # if it's 'not' then we are doing excludes
  'not'     : (_, info) -> info.include = false

# short aliases
commands['-q'] = commands['--quiet']
commands['-g'] = commands['--showgen']
commands['-m'] = commands['--map']

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
      # set into `info` for outputting to the console
      # set into `op` for actual use
      op.inputFile = info.inputFileName = arg

    # if it's a file ending with '.js' then it's the output file
    else if arg[-3...] is '.js' then op.outputFile = arg

    # if it's a file ending with '.json' then it's the options file
    else if arg[-5...] is '.json' then info.optionsFile = arg

    # check for a static arg
    else if commands[arg]? then commands[arg] op, info

    # else it's a module name for either include/exclude
    else
      # optional because if we saw `not` then it's false already
      info.include ?= true

      # store in `exin` to process for generating input
      info.exin.push arg

  return
