TimeAxis    = require '../javascripts/views/TimeAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'
LinearScale = require '../javascripts/util/LinearScale.coffee'
{Surface,
MultiLine}  = ReactCanvas

TimeSeriesChart = React.createClass
  displayName: 'TimeSeriesChart'
  axisThickness: 50

  getInitialState: ->
    loaded: false

  render: ->
    return <div>Loading</div> if not @state.loaded

    labelStyle =
      lineHeight: 20
      height:     20
      fontSize:   12
      color:      'hsl(205, 15%, 51%)'

    <Surface
      top    = 0
      left   = 0
      width  = {@state.timeScale.range[1]}
      height = {@state.temperatureScale.range[1] + @axisThickness}
    >
      <TimeAxis
        axisName      = 'Time'
        scale         = @state.timeScale
        axis          = 'x'
        placement     = 'below'
        direction     = 'right'
        origin        = @state.origin
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
        origin        = @state.origin
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
      points = _.map @state.data, ({time, temperature}) =>
        x: @state.timeScale.map(time) + @state.origin.x
        y: -@state.temperatureScale.map(temperature) + @state.origin.y

      style = {opacity: .5, strokeStyle: 'blue'}

      <MultiLine
        points = points
        style  = style
      />


  setChartDimensions: (callback) ->
    start = new Date(2011, 1, 1).getTime()
    end   = new Date(2012, 6, 1).getTime()

    $parent = $(@getDOMNode()).parent()
    [width, height] = [$parent.width(), $parent.height()]

    origin =
      x: @axisThickness
      y: height - @axisThickness

    timeScale =
      new LinearScale
        domain: [start, end]
        range:  [0, width - origin.x]

    temperatureScale =
      new LinearScale
        domain: [0, 90]
        range:  [0, origin.y]

    @setState(
      {
        width
        height
        origin
        timeScale
        temperatureScale
      }
      => if callback then callback()
    )

  getRandomData: ->
    for tick in @state.timeScale.ticks()
      temp = Math.random() * 90
      {time: tick, temperature: temp}

  # Now that we're loaded in the DOM, use parent to calculate our chart dimensions
  componentDidMount: ->
    @debouncedSetChartDimensions = _.debounce @setChartDimensions, 300
    window.addEventListener 'resize', => @debouncedSetChartDimensions()
    @setChartDimensions =>
      @setState
        data: @getRandomData()
        loaded: true

  componentWillUnmount: ->
    window.removeEventListener 'resize', @debouncedSetChartDimensions

module.exports = TimeSeriesChart