fs           = require 'fs'
path         = require 'path'
_            = require 'lodash'
accord       = require 'accord'
EventEmitter = require('events').EventEmitter
chokidar     = require 'chokidar'

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
 * @param  {Object} argv - command line arguments from argparse
 * @return {Promise} promise for results
###
module.exports.run = (argv) ->
  if not argv.compile or argv.help then return cli.emit('data', help())
  if argv.data? then locals = JSON.parse(argv.data)
  filepath = path.resolve(argv.compile)
  ext = path.extname(filepath).substring(1)
  name = lookupAdapter(ext)

  if not name
    return cli.emit('err', "File extension '#{ext}' not supported".red)

  if not fs.existsSync(filepath)
    return cli.emit('err', "File '#{filepath}' not found ".red)

  adapter = accord.load(name)

  run = -> render(adapter, filepath, locals, cli)
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
 * @return {String|undefined} string adapter name or undefined
###
lookupAdapter = (ext) ->
  for name, Adapter of accord.all()
    if _.contains(Adapter::extensions, ext) then return name
  return

###*
 * Compile and render the file
 * @param  {String} filepath - path to the file
 * @param  {EventEmitter} cli - cli emitter
 * @return {Promise} promise for results
###
render = (adapter, filepath, locals, cli) ->
  adapter.renderFile(filepath, locals).done((res) ->
    cli.emit('data', res)
  )
