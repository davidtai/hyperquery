select = require 'vtree-select'
VNode = require 'virtual-dom/vnode/vnode'
_ = require 'underscore'

class HyperQuery
  selector: ''
  nodes: null
  constructor: (@nodes = [], @selector = '')->
    if !_.isArray @nodes
      @nodes = [@nodes]

  find: (selector)->
    return new HyperQuery(select(selector)(@node), selector)

module.exports =
  $: (something, root)->
    if !something?
      return new HyperQuery
    else if _.isString something && root? && root instanceof VNode
      return new HyperQuery(select(something)(root), selector)
    else if something instanceof VNode
      return new HyperQuery('', s)

    return new HyperQuery

