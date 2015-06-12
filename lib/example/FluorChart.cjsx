{Surface,
Point}       = require 'react-canvas'
React        = require 'react'
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
    </Surface>

  # 30 is the padding I'm using around all of the axis
  getInitialState: ->
    fluorScale = @getFluorScale()
    cycleScale = @getCycleScale()

    {
      fluorScale
      cycleScale
      origin:
        x: 50
        y: fluorScale.range[1]
    }

  renderCycleAxis: ->
    <Axis
      origin = @state.origin
      axis = 'x'
      direction = 'right'
      placement = 'below'
      scale = @state.cycleScale
    />

  renderFluorAxis: ->
    <Axis
      origin = @state.origin
      axis = 'y'
      direction = 'up'
      placement = 'left'
      scale = @state.fluorScale
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