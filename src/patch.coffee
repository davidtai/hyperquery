VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'
h     = require 'virtual-dom/h'

{walk} = require './utils'

qsaSupportedRe = /^[#.][\w-]*$/

patch = ()->
  # Always an element node
  VNode::nodeType = 1
  VNode::style = {}

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

patchedWindow = (win)->
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
  patchedWindow: patchedWindow
  patched: (win)->
    patch(win)

    VNode: VNode
    VText: VText
    h:     h
