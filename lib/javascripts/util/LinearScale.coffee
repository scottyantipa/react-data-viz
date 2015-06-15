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
    @m * x + @b

  invert: (y) ->
    (y - @b) / m

  computeDX: ->
    @dx = Math.abs(@domain[1] - @domain[0])

  computeDY: ->
    @dy = Math.abs(@range[1] - @range[0])

  # This will return an array of domain values
  # which when mapped are all at least minGapInRange apart
  # This useful for rendering labels on an axis
  # TODO: right now it just finds a good multiple of 10, but
  # instead it should smartly find nice even values like 250, 500, 1000, ...
  ticks: (minGapInRange) ->
    multiplier = 0
    base = 10
    foundExp = false
    while not foundExp
      multiplier++
      currentDomainGap = base * multiplier
      foundExp = Math.abs(@map(currentDomainGap)) > minGapInRange

    # now we have the multiple of 10 which nicely divides the domain
    currentVal = @domain[0]
    ticks = [] # always return the first (it should be 0)
    stop = false
    while currentVal < @domain[1]
      ticks.push currentVal
      currentVal = currentVal + base*multiplier

    ticks

module.exports = LinearScale
