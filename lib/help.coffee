antimatter = require 'anti-matter'

module.exports = ->
  antimatter
    title: 'Accord CLI'
    options: { width: 65, color: 'blue' }
    commands: [{
      name: '--compile (-c)'
      required: 'filename'
      description: '[required] Specify a file to compile.'
    }, {
      name: '--out (-o)'
      required: 'filename'
      description: '[optional] Specify a file to pipe the compiled results.'
    }, {
      name: '--watch (-w)'
      description: '[optional] Watch the file for changes and recompile.'
    }, {
      name: '--help (-h)'
      description: 'Display the command help page.'
    }]
