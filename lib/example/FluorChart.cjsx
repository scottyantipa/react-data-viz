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
  axisStyle:
    opacity: .5
    strokeStyle: 'black'
  render: ->
    <div className = '.fluorescense-chart'>
      {@renderStateButtons()}
      <Surface
        top    = 0
        left   = 0
        width  = 900
        height = 500
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

  renderStateButtons: ->
    <div>
      <button
        onClick = { => @setState fluorScale: @getFluorScale(800)}
      >
        800px
      </button>

      <button
        onClick = { => @setState fluorScale: @getFluorScale(400)}
      >
        400px
      </button>
      <button
        onClick = { => @setState fluorScale: @getFluorScale(200)}
      >
        200px
      </button>
    </div>

  renderCycleAxis: ->
    <Axis
      axisName      = 'Cycle'
      origin        = @state.origin
      axis          = 'x'
      direction     = 'right'
      placement     = 'below'
      scale         = @state.cycleScale
      axisLineStyle = @axisStyle
    />

  renderFluorAxis: ->
    <Axis
      axisName      = 'Fluorescense'
      origin        = @state.origin
      axis          = 'y'
      direction     = 'up'
      placement     = 'left'
      scale         = @state.fluorScale
      axisLineStyle = @axisStyle
    />

  # Eventually this should be a MultiARc instead of many individual lines
  renderFluorLines: ->
    numWellsRendered = 0
    linesDrawn = 0
    for wellKey, points of @state.bezierPointsByWellKey
      linesDrawn++
      # add some color just for fun
      style =
        opacity: .8
        strokeStyle:
          if linesDrawn < 20
            'red'
          else if linesDrawn < 40
            'orange'
          else
            'blue'

      pointsForLine = _.map points, ([x,y]) -> {x, y}
      <MultiLine
        points = pointsForLine
        style  = style
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