React = require 'react'
createReactClass = require 'create-react-class'
_ = require 'underscore'
$ = require 'jquery'

{TimeAxis,
Axis,
LinearScale} = ReactDataViz

{Surface,
Group,
Point,
MultiLine} = require 'react-canvas'


###
Example time chart that renders a single line with points.
It has optinos for changing the range of time and range of
temperature (y axis).
This is not exposed by ReactDataViz because it is currently a fairly specific component.
###
TimeSeriesChart = createReactClass
  displayName: 'TimeSeriesChart'
  axisThickness: 100

  getInitialState: ->
    [start, end] = @initRange()
    @incrementDateBy.twoYears end

    tempRange: [0, 100]
    timeRange: [start.getTime(), end.getTime()]
    mounted:   false

  render: ->
    <div className = 'time-series-chart'>
      <div className = 'filters'>
        {@renderTemperatureOptions()}
        {@renderTimeRangeOptions()}
        {@renderDataOptions()}
      </div>
      <div
        className = 'chart'
        ref       = {(node) => @chartNode = node}
      >
        {
          if @state.mounted then @renderChart()
        }
      </div>
    </div>

  renderChart: ->
    [startTime, endTime] = @state.timeRange
    timeScale = @getTimeScale()
    temperatureScale = @getTemperatureScale()

    points = _.map @state.data, ({time, temperature}) =>
      x: timeScale.map(time) + @state.origin.x
      y: -temperatureScale.map(temperature) + @state.origin.y

    lineStyle = {opacity: .5, strokeStyle: 'blue'}

    labelStyle =
      lineHeight: 20
      height:     20
      fontSize:   12
      color:      'hsl(205, 15%, 51%)'

    <Surface
      top    = 0
      left   = 0
      width  = {timeScale.range[1] + 200}
      height = {temperatureScale.range[1] + 200}
    >
      <TimeAxis
        scale         = timeScale
        axis          = 'x'
        placement     = 'below'
        direction     = 'right'
        origin        = @state.origin
        thickness     = @axisThickness
        axisLineStyle = @getAxisLineStyle()
        textStyle     = labelStyle
      />

      <Axis
        axisName        = 'Temp'
        scale           = temperatureScale
        axis            = 'y'
        placement       = 'right'
        direction       = 'up'
        offset          = 1
        otherAxisLength = timeScale.dy
        origin          = @state.origin
        thickness       = @axisThickness
        axisLineStyle   = @getAxisLineStyle()
        textStyle       = labelStyle
        labelForTick    = {(tick) -> "#{tick}˚"}
      />

      <MultiLine
        points = points
        style  = lineStyle
        frame  = {{x: 0, y: 0, width: 0, height: 0}} # used for click events, which we are ignoring for now
      />

      <Group>
        {_.map points, @renderPoint}
      </Group>

    </Surface>

  # Now that we're loaded in the DOM, use parent to calculate our chart dimensions
  componentDidMount: ->
    window.addEventListener 'resize', @setChartDimensions
    @setChartDimensions()

  componentWillUnmount: ->
    window.removeEventListener 'resize', @setChartDimensions

  # Calculate origin, scales, etc
  # Assumes that this is mounted and we can access our parent node
  setChartDimensions: ->
    $chart = $ @chartNode
    [width, height] = [$chart.width(), $chart.height()]

    origin =
      x: @axisThickness
      y: height - @axisThickness

    @setState(
      {width, height, origin}
      =>
        if not @state.data
          @setState
            data: @generateData()
            mounted: true
    )

  generateData: (grain = 'weekly') ->
    timeScale = @getTimeScale()
    tempDelta = @state.tempRange[1] - @state.tempRange[0]
    randTemp = => @state.tempRange[0] + Math.random() * tempDelta

    pointsForStep = (step) ->
      currentTime = timeScale.domain[0]
      data = [currentTime]
      while (currentTime += step) <= timeScale.domain[1]
        data.push
          time:        currentTime
          temperature: randTemp()
      data

    switch grain
      when 'fit'
        for tick in timeScale.ticks()
          temp = randTemp()
          {time: tick, temperature: temp}
      when 'daily'
        pointsForStep 1000 * 60 * 60 * 24
      when 'weekly'
        pointsForStep 1000 * 60 * 60 * 24 * 7
      when 'monthly'
        pointsForStep 1000 * 60 * 60 * 24 * 7 * 4
      when 'yearly'
        pointsForStep 1000 * 60 * 60 * 24 * 7 * 4 * 12

  getTimeScale: ->
    [startTime, endTime] = @state.timeRange
    new LinearScale
      domain: [startTime, endTime]
      range:  [0, @state.width - 2 * @axisThickness]

  getTemperatureScale: ->
    [startTime, endTime] = @state.timeRange
    new LinearScale
      domain: @state.tempRange
      range:  [0, @state.height - 2 * @axisThickness]
      roundDomain: true

  renderPoint: ({x,y}, index) ->
    <Point
      frame  = {{x,y}}
      radius = 2
      style  = {{fillStyle: 'black'}}
      key    = index
    />

  renderDataOptions: ->
    <div className = 'data-options'>
      <span>Data Range</span>
      {
        _.map ['fit', 'daily', 'weekly', 'monthly', 'yearly'], (grain, i) =>
          <button
            onClick = {=> @setState data: @generateData(grain)}
            key     = i
          >
            {grain}
          </button>
      }

    </div>

  renderTemperatureOptions: ->
    <div className = 'tempeature-ranges'>
      <span>Temp range</span>
      <button
        onClick = {=> @setState tempRange: [42,93]}
      >
        42˚ - 93˚
      </button>
      <button
        onClick = {=> @setState tempRange: [0,100]}
      >
        0˚ - 100˚
      </button>
      <button
        onClick = {=> @setState tempRange: [50,50]}
      >
        Collapsed at 50˚
      </button>
    </div>

  renderTimeRangeOptions: ->
    timeFrames = Object.keys @incrementDateBy

    buttons = _.map timeFrames, (timeFrame, i) =>
      onClick = =>
        [start, end] = @initRange()
        @incrementDateBy[timeFrame] end
        @setState
          timeRange: [start.getTime(), end.getTime()]

      <button
        onClick = onClick
        key     = i
        >
        {timeFrame}
      </button>

    <div className = 'time-range-options'>
      <span>Time Range</span>
      {buttons}
    </div>
  #
  # Utils for setting various time ranges
  #

  # All date ranges will start here
  baseDate: -> new Date 2011, 3, 8, 13, 20
  initRange: -> [@baseDate(), @baseDate()]

  incrementDateBy:
    tenSeconds     : (date) -> date.setSeconds date.getSeconds() + 10
    oneMinute      : (date) -> date.setMinutes date.getMinutes() + 1
    halfHour       : (date) -> date.setMinutes date.getMinutes() + 30
    oneHour        : (date) -> date.setHours date.getHours() + 1
    oneDay         : (date) -> date.setDate date.getDate() + 1
    oneMonth       : (date) -> date.setMonth date.getMonth() + 1
    sixMonths      : (date) -> date.setMonth date.getMonth() + 6
    twoYears       : (date) -> date.setYear date.getFullYear() + 2
    tenYears       : (date) -> date.setYear date.getFullYear() + 10
    twoHundredYears: (date) -> date.setYear date.getFullYear() + 200

  getAxisLineStyle: ->
    opacity: .2

module.exports = TimeSeriesChart
