chai = require 'chai'
chai.config.includeStack = true
chai.should()
{expect} = chai

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
  # few random elements we'll search for
  div   = h 'div.bar'
  input = h 'input#some-input', type: 'text', value: 'foo'
  span  = h 'span', 'some text'

  # construct a tree
  tree  = h 'div.foo#some-id', [span, input, div]

  it 'should add getElementById shim to vdom', ->
    $node = Zepto(tree).find '#some-input'
    expect($node[0]).to.eql input

  it 'should add getElementsByTagName shim to vdom', ->
    $node = Zepto(tree).find 'span'
    expect($node[0]).to.eql span

  it 'should add getElementsByClassName shim to vdom', ->
    $node = Zepto(tree).find '.bar'
    expect($node[0]).to.eql div
