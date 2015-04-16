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

module.exports =
  patch: patch
  patched: ->
    patch()

    VNode: VNode
    VText: VText
    h:     h
