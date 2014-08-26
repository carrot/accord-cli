path = require 'path'
packageInfo = require(path.join(__dirname, '../package.json'))
ArgumentParser = require('argparse').ArgumentParser
fs = require 'fs'
path = require 'path'
cli = require './'

argparser = new ArgumentParser(
  version: packageInfo.version
  addHelp: true
  description: packageInfo.description
)
argparser.addArgument(
  ['--compile', '-c']
  type: 'string'
  metavar: 'INFILE'
  help: 'The file to compile'
  required: true
)
argparser.addArgument(
  ['--out', '-o']
  type: 'string'
  metavar: 'OUTFILE'
  help: 'Specify a file to pipe the compiled results. For use where regular
  pipes can\'t be used (like with the --watch arg)'
)
argparser.addArgument(
  ['--watch', '-w']
  action: 'storeTrue'
  help: 'Watch the file for changes and recompile'
)
argparser.addArgument(
  ['--data', '-d']
  type: 'string'
  defaultValue: '{}'
  help: 'Data to be passed to the compiler, formatted as a string of JSON'
)
argv = argparser.parseArgs()

cli.on('data', (data) ->
  if argv.out
    fs.writeFileSync(path.resolve(argv.out), data)
  else
    console.log(data)
)
cli.on('err', console.error.bind(console))
cli.run(argv)
