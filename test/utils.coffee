{walk} = require '../src/utils'

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

describe 'utils/walk', ->
  it 'should find all nodes in a tree', ->
    seen = []
    walk t, (data) ->
      seen.push data.val
    seen.should.eql [1,2,3,4,5]

  it 'should find skip nodes when visitor returns false', ->
    seen = []
    walk t, (data) ->
      seen.push data.val
      return false
    seen.should.eql [1]
