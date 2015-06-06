LinearScale = require './LinearScale.coffee'

class OrdinalScale extends LinearScale

  domain: [] # an ordered set like ["A", "B", "C"...]
  range: []

  # Used to compare to values in scale domain
  # override this in implementation if necessary
  aIsGreater: (a, b) -> a > b

  computeDX: ->
    @dx = @domain.length

  # This is pretty expensive.  I just walk through the whole domain
  # and find the x value that is closest to y when mapped
  invert: (y) ->
    smallestDiff = Infinity
    closestX = null
    for x in @domain
      if (diff = Math.abs(@map(x) - y)) < smallestDiff
        smallestDiff = diff
        closestX = x
    closestX

  # For example, if this is an ordinal scale of natural numbers,
  # we can pass it a real number and we will still map it properly (rather than place
  # it at beginning or end like we would with linearly = false)
  map: (x, linearly = false) ->
    if linearly
      super
    else
      @k * @positionInDomain(x) + @b

  # Different from index in that position can be negative
  # if the x value passed is not in @domain and is less than all values
  positionInDomain: (x) ->
    index = @domain.indexOf x
    if index isnt -1
      index
    else
      if @aIsGreater x, _.last(@domain)
        @domain.length
      else if @aIsGreater @domain[0], x
        -1
  yValueAtZero: ->
    @range[0]

  ticks: (minGapInRange) ->
    @domain

module.exports = OrdinalScale