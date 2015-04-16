class ProductTemplate extends Template
  raw: '''
  <h1 class="product-title"></h1>
  <p class="product-description"></p>
  '''
  bindings:
    name:        'h1'
    description: 'p'

  precompile: ->
    tree = html2hyperscript @raw

    bindings = {}

    for k,v of @bindings
      bindings[k] = []
      matcher = cssauron v
      walktree tree, (node) ->
        if matcher.match node
          bindings.push path

    """
    function template(state) {
      var tree = #{tree};
      var bindings = #{bindings}

      for (var prop in bindings) {
        var val = state[prop];
        state[bindings] = val
      }

      return tree
    }
    """

class Cart extends Model
  defaults:
  validators:
    total: (v) -> v > 0


class CartView extends View
  bindings:
    items: 'ul'

  template: precompile
    '''
    <ul>
    </ul>
    '''

  render: ->
    @renderBindings()

    # show warning if invalid
    for item in @state.items
      unless item.validate()
        @showWarning()

class LineItemView extends View
  bindings:
    name: 'li'

  events:
    'validate:quantity': (ok) ->
      if !ok
        @find('.warning').show()

  template: precompile
    '''
    <li></li>
    <span class="warning">Invaild quantity</span>
    '''

  render: ->
    @find('.warning').show()


class LineItemView extends View
  bindings:
    name: 'li'
    showWarning: '.warning @class'

  events:
    'validate:quantity': (ok) ->
      if !ok
        @state.showWarning = "warning"
      else
        @state.showWarning = "hidden"

  template: precompile
    '''
    <li></li>
    <span class="hidden">Invaild quantity</span>
    '''

class LineItemView extends View
  bindings:
    name: 'li'

  template: precompile
    '''
    <li></li>
    '''

  render: ->
    unless @state.validate 'quantity'
      @append new WarningView()
