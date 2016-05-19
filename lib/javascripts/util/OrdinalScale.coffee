Scale = require './Scale.coffee'
_ = require 'underscore'

# A scale that linearly maps a domain of discrete values into
# a range of continous values.
class OrdinalScale extends Scale

  constructor: ({@domain, @range}) ->
    @dx = @domain.length
    @setup()
  # Passing linearly:true allows you to map values that aren't
  # actually in @domain
  map: (x, linearly = false) ->
    if linearly
      super
    else
      index = @domain.indexOf x
      index * @m

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


  # Different from index in that position can be negative
  # if the x value passed is not in @domain and is less than all values
  positionInDomain: (x) ->
    index = @domain.indexOf x
    if index isnt -1
      index
    else
      if x > _.last(@domain)
        @domain.length
      else if @domain[0] > x
        -1

  yValueAtZero: ->
    @range[0]

  ticks: ->
    @domain

module.exports = OrdinalScale
