VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'
h     = require 'virtual-dom/h'

{walk} = require './utils'

qsaSupportedRe = /^[#.][\w-]*$/

patch = ->
  # Always an element node
  VNode::nodeType = 1

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

    throw 'document.querySelectorAll is not fully implemented'

module.exports =
  patch: patch
  patched: ->
    patch()

    VNode: VNode
    VText: VText
    h:     h
