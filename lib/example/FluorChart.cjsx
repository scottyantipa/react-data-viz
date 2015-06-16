{Surface,
React,
Line}        = ReactCanvas
Axis         = require '../javascripts/views/Axis.cjsx'
OrdinalScale = require '../javascripts/util/OrdinalScale.coffee'
LinearScale  = require '../javascripts/util/LinearScale.coffee'

###
Renders a qCPR line chart showing Fluorescense vs. Cycle
###
FluorChart = React.createClass
  displayName: 'Fluorescense'

  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = {@state.cycleScale.range[1] + 60}
      height = {@state.fluorScale.range[1] + 60}
    >
      {@renderCycleAxis()}
      {@renderFluorAxis()}
      {@renderFluorLines()}
    </Surface>

  # 30 is the padding I'm using around all of the axis
  getInitialState: ->
    fluorScale = @getFluorScale()
    cycleScale = @getCycleScale()
    origin =
      x: 50
      y: fluorScale.range[1]

    # Calculate the qpcr lines
    bezierPointsByWellKey = {}
    for wellKey, results of @props.resultsByWell
      allPoints =
        for {cycle, fluorescense} in results
          [cycle, fluorescense]
      bezierPoints = for x in [1..40]
        [
          origin.x + cycleScale.map(x)
          origin.y - fluorScale.map(allPoints[x - 1][1]) # drawing 'up', so negative
        ]
      bezierPointsByWellKey[wellKey] = bezierPoints
    {
      fluorScale
      cycleScale
      bezierPointsByWellKey
      origin
    }

  renderCycleAxis: ->
    <Axis
      origin    = @state.origin
      axis      = 'x'
      direction = 'right'
      placement = 'below'
      scale     = @state.cycleScale
    />

  renderFluorAxis: ->
    <Axis
      origin    = @state.origin
      axis      = 'y'
      direction = 'up'
      placement = 'left'
      scale     = @state.fluorScale
    />

  # Eventually this should be a MultiARc instead of many individual lines
  renderFluorLines: ->
    numWellsRendered = 0
    for wellKey, points of @state.bezierPointsByWellKey
      break if numWellsRendered is 20
      numWellsRendered++
      for point, index in points
        nextPoint = points[index + 1]
        break if not nextPoint
        frame =
          x0: point[0]
          y0: point[1]
          x1: nextPoint[0]
          y1: nextPoint[1]
        <Line
          frame = frame
        />

  getCycleScale: ->
    new OrdinalScale
      domain: @props.cycleResults.domain
      range: [0, window.innerWidth - 100]
  getFluorScale: ->
    new LinearScale
      domain: @props.fluorResults.domain
      range: [0, 300]


module.exports = FluorChart