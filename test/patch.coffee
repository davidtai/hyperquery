{expect} = require 'chai'

{patched, patchWindow, patch$} = require '../src/patch'
patchWindow(window) if window?

{VNode, VText, h} = patched()
Zepto = require '../src/zepto'
patch$(Zepto)

describe 'patch', ->
  # few random elements we'll search for
  div   = h 'div.bar'
  input = h 'input#some-input', type: 'text', value: 'foo'
  span  = h 'span', 'some text'
  style = h 'div', style: 'display:table;top:100px'
  attr1 = h 'span.attr1'
  attr2 = h 'span.attr2'
  attr3 = h 'span.attr3'
  ul    = h 'ul'

  # construct a tree
  tree  = h 'div.foo#some-id', [span, input, div, attr1, attr2, attr3, ul]

  it 'should add getElementById shim to vdom', ->
    $node = Zepto(tree).find '#some-input'
    expect($node[0]).to.eql input

  it 'should add getElementsByTagName shim to vdom', ->
    $node = Zepto(tree).find 'span'
    expect($node[0]).to.eql span

  it 'should add getElementsByClassName shim to vdom', ->
    $node = Zepto(tree).find '.bar'
    expect($node[0]).to.eql div

  if window?
    it 'should patch getComputedStyle on window', ->
      display = Zepto(style).css 'display'
      top = Zepto(style).css 'top'
      expect(display).to.eql 'table'
      expect(top).to.eql '100px'

    it 'should add removeStyle shim to vdom', ->
      css = h 'div', style: 'display:table;top:100px;background: red'
      #surrounded by other props
      Zepto(css).css 'top', ''
      top = Zepto(css).css 'top'
      expect(top).to.eql undefined
      #malformed
      Zepto(css).css 'background', ''
      bg = Zepto(css).css 'background'
      expect(bg).to.eql undefined
      #ideal
      Zepto(css).css 'display', ''
      display = Zepto(css).css 'display'
      expect(display).to.eql undefined

    it 'should add style.cssText shim to vdom', ->
      css = h 'div', style: 'background: red'
      Zepto(css).css 'display', 'none'
      display = Zepto(css).css 'display'
      expect(display).to.eql 'none'
      bg = Zepto(css).css 'background'
      expect(bg).to.eql 'red'

  else
    it.skip 'should patch getComputedStyle on window', ->
    it.skip 'should add removeStyle shim to vdom', ->
    it.skip 'should add style.cssText to vdom', ->

  it 'should add setAttribute shim to vdom', ->
    $node = Zepto(tree).find '.attr1'
    $node.attr 'x', 1
    expect($node.attr 'x').to.eq 1

  it 'should add getAttribute shim to vdom', ->
    $node = Zepto(tree).find '.attr2'
    $node.attr 'x', 2
    expect($node.attr 'x').to.eq 2

  it 'should add removeAttribute shim to vdom', ->
    $node = Zepto(tree).find '.attr3'
    $node.attr 'x', 1
    $node.attr 'x', 2
    $node.attr 'x', 3
    $node.removeAttr 'x'
    expect($node.attr 'x').to.eq undefined

  it 'should support adjacency operators', ->
    $node = Zepto(tree).find 'ul'
    $node.append h 'li'
    $node.append h 'div'

    $li = $node.find 'li'
    expect($li[0].parentNode).to.eq $node[0]
    expect($li[0].nextSibling.tagName).to.eq 'DIV'
    expect($node[0].children.length).to.eq 2

  it 'should add removeChild shim to vdom', ->
    dumbTree = h 'ul', [h 'li']
    $node = Zepto(dumbTree).find 'li'
    $node2 = $node.remove()
    $node3 = Zepto(dumbTree).find 'li'
    expect($node[0]).to.eq $node2[0]
    expect($node3[0]).to.eq undefined

  it 'should add value shim to vdom', ->
    input = h 'input', value: '100'
    $node = Zepto(input)
    expect($node.val()).to.eq '100'
    $node.val(200)
    expect($node.val()).to.eq '200'

    select = h 'select', [
      h 'option', { value: '100', selected: false }
      h 'option', { value: '200', selected: true }
      h 'option', { value: '300', selected: false }
    ]

    $node = Zepto(select)
    expect($node.val()).to.eq '200'
    $node.val('300')
    expect($node.val()).to.eq '300'

