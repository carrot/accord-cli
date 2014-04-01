path   = require 'path'
fs     = require 'fs'
should = require 'should'
cli    = require '..'
_path  = path.join(__dirname, 'fixtures')

describe 'basic', ->

  it 'basic compile should work', (done) ->
    cli.on 'data', (out) ->
      out.should.eql('<p>bar</p>')
      done()

    cli.run(compile: path.join(_path, 'basic/wow.jade'), foo: 'bar')

  it 'should write to given file path', (done) ->
    _in = path.join(_path, 'basic/wow.jade')
    _out = path.join(_path, 'basic/wow.html')

    cli.on 'done', (out) ->
      fs.existsSync(_out).should.be.ok
      fs.unlinkSync(_out)
      done()

    cli.run(compile: _in, foo: 'bar', out: _out)
