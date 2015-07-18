TimeAxis    = require '../javascripts/views/TimeAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'
LinearScale = require '../javascripts/util/LinearScale.coffee'
{Surface,
Group,
Point,
MultiLine}  = ReactCanvas


###
Example time chart that renders a single line with points.
It has optinos for changing the range of time and range of
temperature (y axis).
###
TimeSeriesChart = React.createClass
  displayName: 'TimeSeriesChart'
  axisThickness: 100

  getInitialState: ->
    [start, end] = @initRange()
    @incrementDateBy.twoYears end

    tempRange:      [0, 100]
    timeRange:      [start.getTime(), end.getTime()]
    dataDispersion: 'weekly' # how much data to show ('ticks' is scale.ticks())

  render: ->
    [startTime, endTime] = @state.timeRange
    timeScale =
      new LinearScale
        domain: [startTime, endTime]
        range:  [0, 800]

    temperatureScale =
      new LinearScale
        domain: @state.tempRange
        range:  [0, 400]

    origin =
      x: @axisThickness
      y: temperatureScale.range[1] + @axisThickness

    data = @generateData timeScale
    points = _.map data, ({time, temperature}) =>
      x: timeScale.map(time) + origin.x
      y: -temperatureScale.map(temperature) + origin.y

    lineStyle = {opacity: .5, strokeStyle: 'blue'}

    labelStyle =
      lineHeight: 20
      height:     20
      fontSize:   12
      color:      'hsl(205, 15%, 51%)'

    <div className = 'time-series-chart'>
      {@renderTemperatureOptions()}
      {@renderTimeRangeOptions()}
      {@renderDataOptions()}
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
          origin        = origin
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
          origin          = origin
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
          {_.map points, (p) => @formatPoint(p)}
        </Group>

      </Surface>
    </div>

  formatPoint: ({x,y}) ->
    <Point
      frame = {{x,y}}
      radius = 2
      style = {{fillStyle: 'black'}}
    />

  renderDataOptions: ->
    <div className = 'data-options'>
      <span>Data Range</span>
      {
        _.map ['fit', 'daily', 'weekly', 'monthly', 'yearly'], (timeGranularity) =>
          <button
            onClick = {=> @setState dataDispersion: timeGranularity}
          >
            {timeGranularity}
          </button>
      }

    </div>

  renderTemperatureOptions: ->
    <div className = 'tempeature-ranges'>
      <span>Temp range</span>
      <button
        onClick = {=> @setState tempRange: [50,90]}
      >
        50˚ - 90˚
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

    buttons = _.map timeFrames, (timeFrame) =>
      onClick = =>
        [start, end] = @initRange()
        @incrementDateBy[timeFrame] end
        @setState
          timeRange: [start.getTime(), end.getTime()]

      <button onClick = onClick>
        {timeFrame}
      </button>

    <div className = 'time-range-options'>
      <span>Time Range</span>
      {buttons}
    </div>
  #
  # Utils for setting various time ranges
  #
  baseDate: -> new Date 2011, 1, 1
  initRange: -> [@baseDate(), @baseDate()]
  incrementDateBy:
    halfHour: (date) ->
      date.setMinutes date.getMinutes() + 30
    oneHour: (date) ->
      date.setHours date.getHours() + 1
    oneDay: (date) ->
      date.setDate date.getDate() + 1
    oneMonth: (date) ->
      date.setMonth date.getMonth() + 1
    sixMonths: (date) ->
      date.setMonth date.getMonth() + 6
    twoYears: (date) ->
      date.setYear date.getFullYear() + 2
    tenYears: (date) ->
      date.setYear date.getFullYear() + 10
    twoHundredYears: (date) ->
      date.setYear date.getFullYear() + 200

  generateData: (timeScale) ->
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
    switch @state.dataDispersion
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

  getAxisLineStyle: ->
    opacity: .2

module.exports = TimeSeriesChart