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
  argv.options ?= {}

  if argv.watch and not argv.file?
    throw new Error("INFILE must be specified to use watch")

  if argv.file?
    filepath = path.resolve(argv.file)
    if not fs.existsSync(filepath)
      throw new Error("File '#{filepath}' not found")

    ext = path.extname(filepath).substring(1)
    name = lookupAdapter(ext)
    if not name
      throw new Error("File extension '#{ext}' not supported")
  else if argv.adapter?
    name = argv.adapter
  else
    throw new Error("INFILE and/or ADAPTER must be specified")

  try
    adapter = accord.load(name)
  catch e
    throw new Error("Adapter '#{name}' is not supported")

  if filepath?
    run = ->
      adapter.renderFile(filepath, argv.options).done((res) ->
        cli.emit('data', res)
      )

    promise = run()

    if argv.watch
      watcher = chokidar.watch(filepath, persistent: true)
      watcher.on('change', run)
      watcher
    else
      promise
  else
    process.stdin.setEncoding 'utf8'
    process.stdin.on 'readable', ->
      buffer = ''
      buffer += chunk while (chunk = process.stdin.read()) isnt null

      #FIXME: I'm not sure why, but stdin is becoming readable more than once
      if buffer is '' then return

      adapter
        .render(buffer, argv.options)
        .done((res) ->
          cli.emit('data', res)
        )

###*
 * Given a file extension, finds the adapter's name in accord, or returns
 * undefined.
 * @param  {String} ext - file extension, no dot
 * @return {String|undefined} string adapter name or undefined
###
lookupAdapter = (ext) ->
  for name, Adapter of accord.all()
    if _.contains(Adapter::extensions, ext) then return name
  return
