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
    command = "./bin/accord -c #{@file}"
    exec(command, silent: true, (code, out) ->
      out.should.eql('<p>bar</p>\n')
      code.should.eql(0)
      done()
    )

  it 'should write to given file path', (done) ->
    command = "./bin/accord -c #{@file} -o #{@out}"
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

    watcher = cli.run(compile: @file, foo: 'bar', watch: true)

  it 'should display help when no commands given', (done) ->
    command = "./bin/accord"
    exec(command, silent: true, (code, out) ->
      out.should.match /Accord CLI/
      code.should.eql(0) # TODO: this shouldn't actually be 0, no args = error
      done()
    )

describe 'with variable', ->
  before ->
    @file = path.join(_path, 'var.jade')
    @out = path.join(_path, 'var.html')

  it 'basic compile should work', (done) ->
    command = "./bin/accord -c #{@file} --foo 'bar'"
    exec(command, silent: true, (code, out) ->
      out.should.eql('<p>bar</p>\n')
      code.should.eql(0)
      done()
    )


  it 'should write to given file path', (done) ->
    command = "./bin/accord -c #{@file} -o #{@out} --foo 'bar'"
    exec(command, silent: true, (code, out) =>
      out.should.eql('')
      code.should.eql(0)
      fs.readFileSync(@out, encoding: 'utf8').should.eql('<p>bar</p>')
      fs.unlinkSync(@out)
      done()
    )
