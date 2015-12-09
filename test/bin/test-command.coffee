assert = require 'assert'
fs = require 'fs'
{join, resolve} = require 'path'
command = require '../../bin/command'


describe 'test command', ->

  it 'with defaults', (done) ->

    cwd = process.cwd()
    moduleOnlyDir = resolve 'test', 'helpers', 'module-only'
    console.log "cwd = [#{cwd}]  chdir = [#{moduleOnlyDir}]"
    process.chdir moduleOnlyDir

    check = (error) ->
      if error? then return done error

      file = 'package.browserified.js'
      assert.equal fs.existsSync(file), true, "should have written `#{file}`"
      fs.unlinkSync file

      process.chdir cwd

      done()

    args = [ '-q' ]

    command
      create:
        args:args
      bonce:
        done:check

  it 'with basedir', (done) ->

    basedir = join 'test', 'helpers', 'module-only'

    check = (error) ->
      if error? then return done error

      file = join basedir, 'package.browserified.js'
      assert.equal fs.existsSync(file), true, "should have written `#{file}`"
      fs.unlinkSync file

      done()

    args = [ basedir, '-q' ]

    command
      create:
        args:args
      bonce:
        done:check
