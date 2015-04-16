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
  tree = h 'div.foo#some-id', [
      h 'span', 'some text' ,
      h 'input#some-input', type: 'text', value: 'foo'
  ]

  it 'should add getElementById shim to vdom', ->
    $node = Zepto(tree).find '#some-input'
    $node[0].tagName.should.eq 'INPUT'

  it 'should add getElementsByTagName shim to vdom', ->
    $node = Zepto(tree).find 'span'
    $node[0].tagName.should.eq 'SPAN'

  it 'should add getElementsByClassName shim to vdom', ->
    $node = Zepto(tree).find '.foo'
    $node[0].tagName.should.eq 'DIV'
