require 'colors'
path   = require 'path'
_      = require 'lodash'
accord = require 'accord'

# return an event emitter
EventEmitter = require('events').EventEmitter
cli = new EventEmitter
module.exports = cli

# run the actual command
module.exports.run = (argv) ->
  locals = get_locals(argv)
  filepath = path.resolve(argv.compile)
  ext = path.extname(filepath).substring(1)

  # adapter lookup
  for k, v of accord.all()
    a = new v
    if _.contains(a.extensions, ext) then name = a.name

  # grab adapter name
  # TODO: need handling for if the adapter isnt installed
  adapter = accord.load(name)

  # render the file
  try
    adapter.renderFile(filepath, locals)
      .then(console.log.bind(console))
      # TODO: need handling for writing to a path
  catch err
    if err.code == 'ENOENT'
      cli.emit('err', "File '#{filepath}' not found ".red)
    else
      cli.emit('err', err)

  return cli

# remove the functional flags, leaving only the locals
get_locals = (argv) ->
  res = _.clone(argv)
  delete res._
  delete res.compile
  delete res.c
  delete res.out
  delete res.o
  delete res.watch
  delete res.w
  return res
