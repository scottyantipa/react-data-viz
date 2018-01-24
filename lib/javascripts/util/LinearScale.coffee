Scale = require './Scale'

# A scale that linearly maps a continuous
# domain into a continous range.
class LinearScale extends Scale

  constructor: ({@domain, @range, roundDomain}) ->
    if roundDomain
      # Expand the domain to "nice" start/end values
      dx = @diffInRange @domain
      if dx isnt 0
        step = @getStep dx
        @domain = [
          Math.floor(@domain[0] / step) * step
          Math.ceil(@domain[1] / step) * step
        ]

    @dx = @diffInRange @domain
    @setup()

module.exports = LinearScale
