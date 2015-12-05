assert = require 'assert'
fs = require 'fs'
{join, resolve} = require 'path'
command = require '../../bin/command'


describe 'test command', ->

  it 'with defaults', (done) ->

    cwd = process.cwd()

    process.chdir join 'test', 'helpers', 'module-only'

    check = (error) ->
      if error? then return done error

      file = 'package.browserified.js'
      assert.equal fs.existsSync(file), true, "should have written `#{file}`"
      fs.unlinkSync file

      file = 'package.browserified.js.map'
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

      file = join basedir, 'package.browserified.js.map'
      assert.equal fs.existsSync(file), true, "should have written `#{file}`"
      fs.unlinkSync file

      done()

    args = [ basedir, '-q' ]

    command
      create:
        args:args
      bonce:
        done:check
