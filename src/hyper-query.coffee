VNode = require 'virtual-dom/vnode/vnode'
VirtualText = require 'virtual-dom/vnode/vtext'
h = require 'virtual-dom/h'

walk = (node, visitor)->
  if (visitor node) == false
    return false

  return unless node.children?

  for child in node.children
    result = walk child, visitor

    if result == false
      return false

VNode.prototype.getElementById = (id)->
  result = null
  walk @, (node) ->
    if node.properties.id == id
      result = node
      return false
  return result

module.exports =
  walk: walk
