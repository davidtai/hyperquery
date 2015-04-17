VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'
h     = require 'virtual-dom/h'
udc   = require 'udc'

{walk} = require './utils'

qsaSupportedRe = /^[#.][\w-]*$/

patch = ->
  # Always an element node
  VNode::nodeType           = 1
  VNode::style              = {}
  VNode::parentNode         = null
  VNode::nextSibling        = null
  VNode::previousSibling    = null
  VNode::firstChild         = null
  VNode::lastChild          = null

  VNode::createElement = (type) ->
    h type

  VNode::getElementById = (id) ->
    result = null
    walk @, (node) ->
      unless node.properties?
        return
      if node.properties.id == id
        result = node
        return false
    return result

  VNode::getElementsByClassName = (className) ->
    result = []
    walk @, (node) ->
      unless node.properties?
        return
      if node.properties.className == className
        result.push node
    return result

  VNode::getElementsByTagName = (tagName) ->
    result = []
    tagName = tagName.toUpperCase()
    walk @, (node) ->
      unless node.tagName?
        return
      if node.tagName == tagName
        result.push node
    return result

  VNode::querySelectorAll = (selector) ->
    if qsaSupportedRe.test selector
      switch selector[0]
        when '.'
          return @getElementsByClassName selector.substring 1
        when '#'
          node = @getElementById selector.substring 1
          if node?
            return [node]
          return []

  VNode::setAttribute = (key, value) ->
    @properties[key] = value

  VNode::getAttribute = (key) ->
    return @properties[key]

  VNode::removeAttribute = (key) ->
    delete @properties[key]

  VNode::cloneNode = (deep) ->
    if deep
      return udc @

    node = {}
    for k,v of @
      node[k] = v

    return node

  setupShimValues= (node)->
    node.style =
      cssText: node.properties.style || ''
    node.firstChild = node.children[0]
    node.lastChild = node.children[node.children.length - 1]
    for i, child of node.children
      child.parentNode = node
      child.nextSibling = node.children[i+1]
      child.previousSibling = node.children[i-1]

  VNode::insertBefore = (newElement, referenceElement)->
    if !referenceElement?
      @children.push newElement
    else
      for i, child of @children
        if child == referenceElement
          parentNode.children.splice i, 0, newElement
          break
    setupShimValues newElement
    setupShimValues @

  originalH = h
  h = require('virtual-dom/h').h = (tagName, properties, children)->
    node = originalH(tagName, properties, children)
    setupShimValues(node)
    return node

patch$ = ($)->
  originalContains = $.contains
  $.contains = (container, contains)->
    if contains instanceof VNode
      return false
    else return originalContains.call(@, container, contains)

patchWindow = (win)->
  if win? && win.getComputedStyle?
    nativeGetComputedStyle = win.getComputedStyle
    win.getComputedStyle = (element, pseudo)->
      if element instanceof VNode
        return {
          getPropertyValue: (property)->
            styleStr = element.properties.style
            if styleStr?
              styles = styleStr.split ';'
              for style in styles
                styleTokens = style.split ':'
                if styleTokens[0] == property
                  return styleTokens[1]
            return
        }
      else
        return nativeGetComputedStyle(element, pseudo)

module.exports =
  patch: patch
  patch$: patch$
  patchWindow: patchWindow
  patched: (win)->
    patch(win)

    VNode: VNode
    VText: VText
    h:     h
