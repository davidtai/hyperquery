VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'
h     = require 'virtual-dom/h'
udc   = require 'udc'

{walk} = require './utils'

qsaSupportedRe = /^[#.][\w-]*$/

patch = ->
  VText::properties = {}

  # Always an element node
  VText::nodeType           = VNode::nodeType           = 1
  VText::style              = VNode::style              = {}
  VText::parentNode         = VNode::parentNode         = null
  VText::nextSibling        = VNode::nextSibling        = null
  VText::previousSibling    = VNode::previousSibling    = null
  VText::firstChild         = VNode::firstChild         = null
  VText::lastChild          = VNode::lastChild          = null

  VText::createElement = VNode::createElement = (type) ->
    h type

  VText::getElementById = VNode::getElementById = (id) ->
    result = null
    walk @, (node) ->
      unless node.properties?
        return
      if node.properties.id == id
        result = node
        return false
    return result

  VText::getElementsByClassName = VNode::getElementsByClassName = (className) ->
    result = []
    walk @, (node) ->
      unless node.properties?
        return
      if node.properties.className == className
        result.push node
    return result

  VText::getElementsByTagName = VNode::getElementsByTagName = (tagName) ->
    result = []
    tagName = tagName.toUpperCase()
    walk @, (node) ->
      unless node.tagName?
        return
      if node.tagName == tagName
        result.push node
    return result

  VText::querySelectorAll = VNode::querySelectorAll = (selector) ->
    if qsaSupportedRe.test selector
      switch selector[0]
        when '.'
          return @getElementsByClassName selector.substring 1
        when '#'
          node = @getElementById selector.substring 1
          if node?
            return [node]
          return []

  VText::setAttribute = VNode::setAttribute = (key, value) ->
    @properties[key] = value

  VText::getAttribute = VNode::getAttribute = (key) ->
    return @properties[key]

  VText::removeAttribute = VNode::removeAttribute = (key) ->
    delete @properties[key]

  VText::cloneNode = VNode::cloneNode = (deep) ->
    if deep
      return udc @

    node = {}
    for k,v of @
      node[k] = v

    return node

  setupShimValues= (node)->
    node.style =
      cssText: node.properties.style || ''
      removeProperty: (property)->
        propRE = new RegExp property + '\\s*?:.*?(;|$)'
        node.style.cssText = node.style.cssText.replace propRE, ''
    node.firstChild = node.children[0]
    node.lastChild = node.children[node.children.length - 1]
    i = 0
    for child in node.children
      child.parentNode = node
      child.nextSibling = node.children[i+1]
      child.previousSibling = node.children[i-1]
      i++

  VText::insertBefore = VNode::insertBefore = (newElement, referenceElement)->
    if !referenceElement?
      @children.push newElement
    else
      i = 0
      for child in @children
        if child == referenceElement
          parentNode.children.splice i, 0, newElement
          break
        i++
    setupShimValues newElement
    setupShimValues @

    return newElement

  VText::appendChild = VNode::appendChild = (node)->
    @children.push node
    setupShimValues node
    setupShimValues @

    return node

  VText::removeChild = VNode::removeChild = (node)->
    i = 0
    for child in @children
      if child == node
        @children.splice i, 1
        setupShimValues node
        setupShimValues @
        return node
      i++
    throw new Error('Node is not a child')

  originalH = h
  h = require('virtual-dom/h').h = (tagName, properties, children)->
    node = originalH(tagName, properties, children)
    setupShimValues(node)
    return node

patch$ = ($)->
  originalContains = $.contains
  $.contains = (container, contains)->
    if contains instanceof VNode || element instanceof VText
      return false
    return originalContains.apply @, arguments

  originalCss = $.fn.css
  $.fn.css = (property, value)->
    for node in @
      node.style.cssText = node.properties.style || ''
    ret = originalCss.apply @, arguments
    for node in @
      node.properties.style = node.style.cssText
    return ret

  originalVal = $.fn.val
  $.fn.val = (value)->
    for node in @
      if node.tagName == 'INPUT'
        #softhook
        node.value = ''+node.properties.value.value || ''
      else if node.tagName == 'SELECT'
        node.multiple = node.properties.multiple || undefined
        for child in node.children
          if child.tagName == 'OPTION'
            child.selected = child.properties.selected || undefined
            child.value = ''+child.properties.value || ''
            node.value = child.value if child.selected
      else
        node.value = node.properties.value || ''
    ret = originalVal.apply @, arguments
    for node in @
      if node.tagName == 'INPUT'
        #softhook
        node.properties.value.value = node.value
      else if node.tagName == 'SELECT'
        for child in node.children
          if child.tagName == 'OPTION'
            if ret.value instanceof Array
              child.properties.selected = child.value in ret.value
            else
              child.properties.selected = child.value == ret.value
            child.properties.value = child.value
      else
        node.properties.value = node.value
    return ret

patchWindow = (win)->
  if win? && win.getComputedStyle?
    nativeGetComputedStyle = win.getComputedStyle
    win.getComputedStyle = (element, pseudo)->
      if element instanceof VNode
        return {
          getPropertyValue: (property)->
            propRE = new RegExp property + '\\s*?:\\s*(.*?)\\s*(;|$)'
            value = element.properties.style.match propRE
            if value?
              return value[1]
            return undefined
        }
      else if element instanceof VText
        return {
          getPropertyValue: (property)->
            return undefined
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
