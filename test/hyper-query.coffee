chai = require('chai')
chai.config.includeStack = true
should = chai.should()

HQ = require '../src/hyper-query'

describe 'walk', ->
  it 'should walk a tree', ->
    t =
      val: 1
      children: [
        {
          val: 2
        }
        {
          val: 3
          children: [
            val: 4
            val: 5
          ]
        }
      ]

    HQ.walk t, (data) ->



