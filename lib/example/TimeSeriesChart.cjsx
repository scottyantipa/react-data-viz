TimeAxis    = require '../javascripts/views/TimeAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'
LinearScale = require '../javascripts/util/LinearScale.coffee'
{Surface,
MultiLine}  = ReactCanvas

TimeSeriesChart = React.createClass
  displayName: 'TimeSeriesChart'
  axisThickness: 100
  render: ->
    origin = @getOrigin()
    labelStyle =
      lineHeight: 20
      height:     20
      fontSize:   12
      color:      'hsl(205, 15%, 51%)'

    <Surface
      top    = 0
      left   = 0
      width  = {@state.timeScale.range[1] + 200}
      height = {@state.temperatureScale.range[1] + 200}
    >
      <TimeAxis
        axisName      = 'Time'
        scale         = @state.timeScale
        axis          = 'x'
        placement     = 'below'
        direction     = 'right'
        origin        = origin
        thickness     = @axisThickness
        axisLineStyle = @getAxisLineStyle()
        textStyle     = labelStyle
      />

      <Axis
        axisName      = 'Temp'
        scale         = @state.temperatureScale
        axis          = 'y'
        placement     = 'left'
        direction     = 'up'
        origin        = @getOrigin()
        thickness     = @axisThickness
        axisLineStyle = @getAxisLineStyle()
        textStyle     = labelStyle
        labelForTick  = {(tick) -> "#{tick}˚"}
      />

      {@renderTemperatureLine()}

    </Surface>

  getAxisLineStyle: ->
    opacity: .2

  renderTemperatureLine: ->
      origin = @getOrigin()
      points = _.map @state.data, ({time, temperature}) =>
        x: @state.timeScale.map(time) + origin.x
        y: -@state.temperatureScale.map(temperature) + origin.y

      style = {opacity: .5, strokeStyle: 'blue'}

      <MultiLine
        points = points
        style  = style
      />

  getOrigin: ->
    x: @axisThickness
    y: @state.temperatureScale.range[1] + @axisThickness

  getInitialState: ->
    start = new Date(2011, 1, 1).getTime()
    end   = new Date(2012, 6, 1).getTime()

    timeScale =
      new LinearScale
        domain: [start, end]
        range:  [0, 500]

    temperatureScale =
      new LinearScale
        domain: [0, 90]
        range:  [0, 500]

    data =
      for tick in timeScale.ticks()
        temp = Math.random() * 90
        {time: tick, temperature: temp}

    # have the final value be at 40 just because it's good to
    # visually see the y min value being rendered in the right place
    data.push {time: end, temperature: 40}

    {timeScale, temperatureScale, data}

module.exports = TimeSeriesChart