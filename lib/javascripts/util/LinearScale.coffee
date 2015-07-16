# A simple 1 to 1 scale
# x is the domain, y is the range

# NOTE: only working for positive values
class LinearScale
  domain: []
  range: []
  dx: 1 # change in domain
  dy: 1 # change in

  # y = mx + b
  m: null
  b: null

  constructor: ({@domain, @range}) ->
    @computeDX()
    @computeDY()
    @m =  @dy / @dx

    # Find y intercept (the 'b' in y = mx + b)
    @b = @range[0] - (@m * @domain[0]) # just a simple y = mx + b subsitution

  map: (x) ->
    if @dx is 0
      @range[0] + .5 * @dy
    else
      @m * x + @b

  invert: (y) ->
    (y - @b) / m

  computeDX: ->
    @dx = Math.abs(@domain[1] - @domain[0])

  computeDY: ->
    @dy = Math.abs(@range[1] - @range[0])

  # calculate a good gap between domain values as a power of 10
  getStep: ->
    exp = Math.floor Math.log(@dx) / Math.LN10
    step = Math.pow 10, exp

  # This will return an array of domain values separated by a power of 10
  ticks: (minGapInRange) ->
    if @dx is 0
      return [@domain[0]]
    step = @getStep()
    currentVal = @domain[0]
    ticks = [] # always return the first (it should be 0)
    while currentVal <= @domain[1]
      ticks.push currentVal
      currentVal = currentVal + step

    ticks

module.exports = LinearScale
