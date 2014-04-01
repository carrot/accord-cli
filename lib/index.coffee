require 'colors'
fs     = require 'fs'
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

  if not name then return cli.emit('err', "File extension '#{ext}' not supported".red)

  # grab adapter
  adapter = accord.load(name, resolve_path(name))

  # render the file
  try
    promise = adapter.renderFile(filepath, locals)
  catch err
    if err.code == 'ENOENT'
      cli.emit('err', "File '#{filepath}' not found ".red)
    else
      cli.emit('err', err)
    return cli

  # now decide how to render the output
  if argv.out
    promise.then((o) -> fs.writeFileSync(path.resolve(argv.out), o))
  else
    promise.then(console.log.bind(console))

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

# can be found in accord's source
resolve_path = (name) ->
  _path = require.resolve(name).split(path.sep).reverse()
  for p, i in _path
    if _path[i - 1] is name and p is 'node_modules' then break
  _.first(_path.reverse(), _path.length - i + 1).join(path.sep)
