path   = require 'path'
fs     = require 'fs'
should = require 'should'
cli    = require '..'
_path  = path.join(__dirname, 'fixtures')

describe 'basic', ->

  before ->
    @file = path.join(_path, 'basic/wow.jade')
    @out = path.join(_path, 'basic/wow.html')

  it 'basic compile should work', (done) ->
    cli.once 'data', (out) ->
      out.should.eql('<p>bar</p>')
      done()

    cli.run(compile: @file, foo: 'bar')

  it 'should write to given file path', (done) ->

    cli.run(compile: @file, foo: 'bar', out: @out).then =>
      fs.existsSync(@out).should.be.ok
      fs.unlinkSync(@out)
      done()

  it 'should watch a file for changes', (done) ->
    i = 0

    listener = (out) =>
      i++
      if i == 1
        out.should.eql('<p>bar</p>')
        setTimeout((=> fs.writeFileSync(@file, "p foo")), 100) 
      if i == 2
        out.should.eql('<p>foo</p>')
        watcher.close()
        fs.writeFileSync(@file, "p bar")
        cli.removeListener('data', listener)
        done()

    cli.on('data', listener)

    watcher = cli.run(compile: @file, foo: 'bar', watch: true)
