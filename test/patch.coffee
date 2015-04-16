chai = require 'chai'
# chai.config.includeStack = true
chai.should()

zeptoPath = require.resolve 'npm-zepto'
domino    = require 'domino'
vm        = require 'vm'
fs        = require 'fs'

{patched} = require '../src/patch'

# Create window + use sandbox to safely require Zepto
window = domino.createWindow()
sandbox =
  window: window
  getComputedStyle: window.getComputedStyle

vm.createContext sandbox
zeptoCode = fs.readFileSync zeptoPath, 'utf8'
vm.runInContext zeptoCode, sandbox

{Zepto} = sandbox
{VNode, VText, h} = patched()

describe 'patch', ->
  it 'should make virtual-dom zepto-compatible', ->
    tree = h 'div.foo#some-id', [
        h 'span', 'some text' ,
        h 'input#some-input', type: 'text', value: 'foo'
    ]

    input = Zepto(tree).find '#some-input'
    input[0].tagName.should.eq 'INPUT'
