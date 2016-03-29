# This is an abstract class, meant to be extended
# See classes LinearScale and OrdinaleScale for example subclasses
class Scale
  domain: []
  range:  []
  dx: 1 # change in domain
  dy: 1 # change in range

  # y = mx + b
  m: null
  b: null

  # Call this from subclass constructor once it
  # it has initialized @range and @domain
  setup: ->
    @dy = @diffInRange @range
    @m  =  @dy / @dx
    @b  = @computeIntercept()

  map: (x) ->
    if @dx is 0
      @range[0] + .5 * @dy
    else
      @m * x + @b

  invert: (y) ->
    (y - @b) / m

  diffInRange: (rangeDelta) ->
    Math.abs rangeDelta[1] - rangeDelta[0]

  # Find y intercept (the 'b' in y = mx + b)
  computeIntercept: ->
    @range[0] - (@m * @domain[0])

  # calculate a good gap between domain values as a power of 10
  getStep: (domainDelta) ->
    exp = Math.floor Math.log10 domainDelta
    Math.pow 10, exp

  # This will return an array of domain values separated by a power of 10
  ticks: (minGapInRange) ->
    if @dx is 0
      return [@domain[0]]
    step = @getStep @dx
    currentVal = @domain[0]
    ticks = [] # always return the first (it should be 0)
    while currentVal <= @domain[1]
      ticks.push currentVal
      currentVal = currentVal + step

    ticks

module.exports = Scale
