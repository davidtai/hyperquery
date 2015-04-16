walk = (node, visitor)->
  if (visitor node) == false
    return false

  return unless node.children?

  for child in node.children
    result = walk child, visitor

    if result == false
      return false

module.exports =
  walk: walk
