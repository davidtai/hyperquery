VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'
h     = require 'virtual-dom/h'

{walk} = require './utils'

patch = ->
  VNode::createElement = (type) ->
    h type

  VNode::getElementById = (id) ->
    result = null
    walk @, (node) ->
      if node.properties.id == id
        result = node
        return false
    return result

  VNode::getElementsByClassName = (className) ->
    result = []
    walk @, (node) ->
      if node.properties.className == className
        result.push node
    return result

  VNode::getElementsByTagName = (tagName) ->
    result = []
    tagName = tagName.toUpperCase()
    walk @, (node) ->
      if node.tagName == tagName
        result.push node
    return result

module.exports =
  patch: patch
  patched: ->
    patch()

    VNode: VNode
    VText: VText
    h:     h
