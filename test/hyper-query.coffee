chai = require('chai')
chai.config.includeStack = true
should = chai.should()

HQ = require '../src/hyper-query'

describe 'walk', ->
  t =
    val: 1
    children: [
      val: 2
    ,
      val: 3
      children: [
          val: 4
        ,
          val: 5
      ]
    ]

  it 'should find all nodes in a tree', ->
    seen = []
    HQ.walk t, (data) ->
      seen.push data.val
    JSON.stringify(seen.sort()).should.eq "[1,2,3,4,5]"

  it 'should find skip nodes when visitor returns false', ->
    seen = []
    HQ.walk t, (data) ->
      seen.push data.val
      return false
    JSON.stringify(seen.sort()).should.eq "[1]"
