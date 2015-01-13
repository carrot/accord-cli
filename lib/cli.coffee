path = require 'path'
packageInfo = require(path.join(__dirname, '../package.json'))
ArgumentParser = require('argparse').ArgumentParser
fs = require 'fs'
cli = require './'

argparser = new ArgumentParser(
  version: packageInfo.version
  addHelp: true
  description: packageInfo.description
)
argparser.addArgument(
  ['file']
  nargs: '?'
  type: 'string'
  metavar: 'INFILE'
  help: 'The file to compile. If omitted, accord will read from STDIN.'
)
argparser.addArgument(
  ['--adapter']
  type: 'string'
  help: 'The accord adapter to use for compiling the file. If omitted, this will
  be deduced from the INFILE\'s extension. If INFILE is omitted and the input is
  passed via STDIN, then this is required.'
)
argparser.addArgument(
  ['--out']
  type: 'string'
  metavar: 'OUTFILE'
  help: 'Specify a file to pipe the compiled results. For use where regular
  pipes can\'t be used (like with the --watch arg)'
)
argparser.addArgument(
  ['--watch', '-w']
  action: 'storeTrue'
  help: 'Watch the file for changes and recompile. INFILE must be specified to
  use this'
)
argparser.addArgument(
  ['--options', '-o']
  type: 'string'
  defaultValue: '{}'
  help: 'Options to be passed to the compiler, formatted as a string of JSON'
)
argv = argparser.parseArgs()

# pass options as an object rather than a string
argv.options = JSON.parse(argv.options)

cli.on('data', (data) ->
  if argv.out
    fs.writeFileSync(path.resolve(argv.out), data)
  else
    process.stdout.write(data)
)
cli.on('err', console.error.bind(console))
cli.run(argv)
