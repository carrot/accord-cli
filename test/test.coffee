require 'shelljs/global'
path   = require 'path'
fs     = require 'fs'
should = require 'should'
cli    = require '..'
_path  = path.join(__dirname, 'fixtures')

describe 'basic', ->
  before ->
    @file = path.join(_path, 'basic.jade')
    @out = path.join(_path, 'basic.html')

  it 'basic compile should work', (done) ->
    command = "./bin/accord #{@file}"
    exec(command, silent: true, (code, out) ->
      out.should.eql('<p>bar</p>')
      code.should.eql(0)
      done()
    )

  it 'should write to given file path', (done) ->
    command = "./bin/accord #{@file} --out #{@out}"
    exec(command, silent: true, (code, out) =>
      out.should.eql('')
      code.should.eql(0)
      fs.readFileSync(@out, encoding: 'utf8').should.eql('<p>bar</p>')
      fs.unlinkSync(@out)
      done()
    )

  it 'should watch a file for changes', (done) ->
    i = 0

    listener = (out) =>
      i++
      if i is 1
        out.should.eql('<p>bar</p>')
        setTimeout((=> fs.writeFileSync(@file, 'p foo\n')), 100)
      if i is 2
        out.should.eql('<p>foo</p>')
        watcher.close()
        fs.writeFileSync(@file, 'p bar\n')
        cli.removeListener('data', listener)
        done()

    cli.on('data', listener)

    watcher = cli.run(file: @file, watch: true)

  it 'should display help with "-h"', (done) ->
    command = "./bin/accord -h"
    exec(command, silent: true, (code, out) ->
      out.should.match /accord \[-h\] \[-v\]/
      code.should.eql(0)
      done()
    )

  it 'should fail when called without args', (done) ->
    command = "./bin/accord"
    exec(command, silent: true, (code, out) ->
      out.should.match /INFILE and\/or ADAPTER must be specified/
      code.should.eql(8)
      done()
    )

describe 'with variable', ->
  before ->
    @file = path.join(_path, 'var.jade')
    @out = path.join(_path, 'var.html')

  it 'basic compile should work', (done) ->
    command = "./bin/accord #{@file} -o '{\"foo\":\"bar\"}'"
    exec(command, silent: true, (code, out) ->
      out.should.eql('<p>bar</p>')
      code.should.eql(0)
      done()
    )


  it 'should write to given file path', (done) ->
    command = "./bin/accord #{@file} --out #{@out} -o '{\"foo\":\"bar\"}'"
    exec(command, silent: true, (code, out) =>
      out.should.eql('')
      code.should.eql(0)
      fs.readFileSync(@out, encoding: 'utf8').should.eql('<p>bar</p>')
      fs.unlinkSync(@out)
      done()
    )
