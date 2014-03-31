should = require 'should'
accord_cli = require '..'

describe 'basic', ->

  it 'should work', ->
    accord_cli.should.eql 'wow'
