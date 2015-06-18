TimeAxis    = require '../javascripts/views/TimeAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'
LinearScale = require '../javascripts/util/LinearScale.coffee'
{Surface}   = ReactCanvas

TimeSeriesChart = React.createClass
  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = {@state.timeScale.range[1] + 100}
      height = {@state.temperatureScale.range[1] + 100}
    >
      <TimeAxis
        scale        = @state.timeScale
        axis         = 'x'
        placement    = 'below'
        direction    = 'right'
        origin       = @getOrigin()
      />

      <Axis
        scale     = @state.temperatureScale
        axis      = 'y'
        placement = 'left'
        direction = 'up'
        origin    = @getOrigin()
      />

    </Surface>


  displayName: 'TimeSeriesChart'

  getOrigin: ->
    x: 50
    y: @state.temperatureScale.range[1] + 50

  getInitialState: ->
    start = new Date(2011, 1, 1)
    end   = new Date(2012,1,1)

    timeScale:
      new LinearScale
        domain: [start.getTime(), end.getTime()]
        range:  [0, 500]
    temperatureScale:
      new LinearScale
        domain: [40, 80]
        range:  [0, 400]


module.exports = TimeSeriesChart