require 'colors'
fs           = require 'fs'
path         = require 'path'
_            = require 'lodash'
accord       = require 'accord'
EventEmitter = require('events').EventEmitter
chokidar     = require 'chokidar'
help         = require './help'

module.exports = cli = new EventEmitter

###*
 * The main export has to be the event emitter to be able to correctly
 * attach events before run. This function actually runs the cli logic,
 * given an arguments object.
 *
 * First, we get some information we'll need - the locals passed in, the
 * path to the file being compiled, the file's extension, and the adapter
 * being used to compile it.
 *
 * Then we handle common errors - if the file type isn't supported by accord
 * or if the actual file passed in was not found.
 *
 * After this, we grab the adapter and try to compile the file. If there
 * was a compile error, that's emitted. If not, we either write or log the
 * results.
 *
 * @param  {Object} argv - command line arguments, parsed by minimist
 * @return {Promise} promise for results
###
module.exports.run = (argv) ->
  if not argv.compile or argv.help then return cli.emit('data', help())

  locals = getLocals(argv)
  filepath = path.resolve(argv.compile)
  ext = path.extname(filepath).substring(1)
  name = lookupAdapter(ext)

  if not name
    return cli.emit('err', "File extension '#{ext}' not supported".red)

  if not fs.existsSync(filepath)
    return cli.emit('err', "File '#{filepath}' not found ".red)

  adapter = accord.load(name, resolvePath(name))

  run = -> render(adapter, filepath, locals, cli, argv)
  promise = run()

  if argv.watch
    watcher = chokidar.watch(filepath, persistent: true)
    watcher.on('change', run)
    watcher
  else
    promise

###*
 * Given a file extension, finds the adapter's name in accord, or
 * returns undefined.
 * @param  {String} ext - file extension, no dot
 * @return {?} string adapter name or undefined
###
lookupAdapter = (ext) ->
  for name, Adapter of accord.all()
    a = new Adapter
    if _.contains(a.extensions, ext) then return a.name
  return

###*
 * Given the name of a module, returns it's home folder in node
 * modules. This was taken from accord's source.
 * @param  {String} name - name of a node module
 * @return {String} path to the module
###
resolvePath = (name) ->
  _path = require.resolve(name).split(path.sep).reverse()
  for p, i in _path
    if _path[i - 1] is name and p is 'node_modules' then break
  _.first(_path.reverse(), _path.length - i + 1).join(path.sep)

###*
 * Compile and render the file
 * @param  {String} filepath - path to the file
 * @param  {EventEmitter} cli - cli emitter
 * @param  {Object} argv - arguments object
 * @return {Promise} a promise for the result
###
render = (adapter, filepath, locals, cli, argv) ->
  cli.emit('start')

  adapter.renderFile(filepath, locals)
    .catch(cli.emit.bind(cli, 'err'))
    .then((o) ->
      if argv.out
        fs.writeFileSync(path.resolve(argv.out), o)
      else
        cli.emit('data', o)
    )
    .then(cli.emit.bind(cli, 'done'))

###*
 * Remove the functional flags, leaving only the 'locals'.
 * @param  {Object} argv - args object, parsed my minimist
 * @return {Object} cloned object, pruned of all functional keys
###
getLocals = (argv) ->
  res = _.clone(argv)
  delete res._
  delete res.compile
  delete res.c
  delete res.out
  delete res.o
  delete res.watch
  delete res.w
  delete res.help
  delete res.h
  return res
