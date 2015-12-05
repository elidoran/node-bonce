module.exports = (op, info) -> #include, exin, inputFileName, optionsFile

  # output the options used in the operation unless `quiet` was specified
  unless op.quiet
    includeLabel = if info.include or not info.include? then 'include' else 'exclude'
    exinValue =
      if info.include? then (v.path for k,v of info.exin)
      else if info.inputFileName? then '<see input file>'
      else '<all>'

    console.log """
    bonce options:
    -----------------------------------------------------------------
             cwd: #{process.cwd()}
         basedir: #{op.options.basedir}
           input: #{info.inputFileName ? '<generated>'}
          output: #{op.outputFile}
         options: #{info.optionsFile ? '<none>'}
      transforms: #{(t.name for t in op.transforms)}
        map path: #{op.mapPath}
         #{includeLabel}: #{exinValue}
    -----------------------------------------------------------------
    """

  return
