browserZepto = ->
  require 'npm-zepto'

nodeZepto = ->
  zeptoPath = require.resolve 'npm-zepto'

  # Terrible hack to prevent any of this getting bundled in the client.
  eval """
       domino = require('domino');
       fs     = require('fs');
       vm     = require('vm');
       """

  # Create window + use sandbox to safely require Zepto
  window = domino.createWindow()

  sandbox =
    window: window
    getComputedStyle: window.getComputedStyle

  vm.createContext sandbox
  zeptoCode = fs.readFileSync zeptoPath, 'utf8'
  vm.runInContext zeptoCode, sandbox

  sandbox.Zepto

if typeof window == 'undefined'
  module.exports = nodeZepto()
else
  module.exports = browserZepto()
