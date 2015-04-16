VNode = require 'virtual-dom/vnode/vnode'
VirtualText = require 'virtual-dom/vnode/vtext'
h = require 'virtual-dom/h'

$ = require 'npm-zepto'

walk = (node, visitor)->
  if vistor node == false
    return false

  for child in @children
    if walk child, visitor == false
      return false

  return true

VNode.prototype.getElementById = (id)->
  result = null
  walk @, (node)->
    if node.properties.id == id
      result = node
      return false
  return result

module.exports =
  $: $
  walk: walk
