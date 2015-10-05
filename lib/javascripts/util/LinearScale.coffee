Scale = require './Scale.coffee'

# A scale that linearly maps a continuous
# domain into a continous range.
class LinearScale extends Scale

  constructor: ({@domain, @range}) ->
    @dx = @diffInRange @domain
    @setup()

module.exports = LinearScale
