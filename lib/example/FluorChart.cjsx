{Surface,
MultiLine}   = ReactCanvas
Axis         = require '../javascripts/views/Axis.cjsx'
OrdinalScale = require '../javascripts/util/OrdinalScale.coffee'
LinearScale  = require '../javascripts/util/LinearScale.coffee'

###
Renders a qCPR line chart showing Fluorescense vs. Cycle
###
FluorChart = React.createClass
  displayName: 'Fluorescense'

  render: ->
    <div className = '.fluorescense-chart'>
      <button
        onClick = { => @setState fluorScale: @getFluorScale(400)}
      >
        400px
      </button>
      <Surface
        top    = 0
        left   = 0
        width  = {@state.cycleScale.range[1] + 200}
        height = {@state.fluorScale.range[1] + 200}
      >
        {@renderCycleAxis()}
        {@renderFluorAxis()}
        {@renderFluorLines()}
      </Surface>
    </div>

  # 30 is the padding I'm using around all of the axis
  getInitialState: ->
    fluorScale = @getFluorScale()
    cycleScale = @getCycleScale()
    origin =
      x: 50
      y: fluorScale.range[1] + 80

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
      axisName  = 'Cycle'
      origin    = @state.origin
      axis      = 'x'
      direction = 'right'
      placement = 'below'
      scale     = @state.cycleScale
    />

  renderFluorAxis: ->
    <Axis
      axisName  = 'Fluorescense'
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
      pointsForLine = _.map points, ([x,y]) -> {x, y}
      <MultiLine
        points = pointsForLine
      />

  getCycleScale: ->
    new OrdinalScale
      domain: @props.cycleResults.domain
      range: [0, window.innerWidth - 100]
  getFluorScale: (range1 = 300) ->
    new LinearScale
      domain: @props.fluorResults.domain
      range: [0, range1]


module.exports = FluorChart