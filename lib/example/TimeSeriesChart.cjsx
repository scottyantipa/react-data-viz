TimeAxis    = require '../javascripts/views/TimeAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'
LinearScale = require '../javascripts/util/LinearScale.coffee'
{Surface,
MultiLine}  = ReactCanvas

TimeSeriesChart = React.createClass
  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = {@state.timeScale.range[1] + 100}
      height = {@state.temperatureScale.range[1] + 100}
    >
      <TimeAxis
        axisName     = 'Time'
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

      {@renderTemperatureLine()}

    </Surface>


  displayName: 'TimeSeriesChart'

  renderTemperatureLine: ->
      origin = @getOrigin()
      points = _.map @state.data, ({time, temperature}) =>
        x: @state.timeScale.map(time) + origin.x
        y: -@state.temperatureScale.map(temperature) + origin.y

      <MultiLine
        points = points
      />

  getOrigin: ->
    x: 50
    y: @state.temperatureScale.range[1] + 50

  getInitialState: ->
    start = new Date(2011, 1, 1).getTime()
    end   = new Date(2012, 1, 1).getTime()

    timeScale =
      new LinearScale
        domain: [start, end]
        range:  [0, 500]

    temperatureScale =
      new LinearScale
        domain: [40, 80]
        range:  [0, 400]

    data =
      for tick in timeScale.ticks()
        temp = 40 + Math.random() * 40
        {time: tick, temperature: temp}

    {timeScale, temperatureScale, data}

module.exports = TimeSeriesChart