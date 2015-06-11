{Surface,
Point}      = require 'react-canvas'
React       = require 'react'
OrdinalAxis = require '../javascripts/views/OrdinalAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'

###
Renders a qCPR line chart showing Fluorescense vs. Cycle
###
FluorChart = React.createClass
  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = {@props.cycleScale.range[1] + 60}
      height = {@props.fluorScale.range[1] + 60}
    >
      {@renderCycleAxis()}
      {@renderFluorAxis()}
    </Surface>

  # 30 is the padding I'm using around all of the axis
  getInitialState: ->
    origin:
      x: 30
      y: @props.fluorScale.range[1]

  displayName: 'Fluorescense'

  propTypes:
    cycleScale: React.PropTypes.object.isRequired
    fluorScale: React.PropTypes.object.isRequired

  renderCycleAxis: ->
    <Axis
      origin = @state.origin
      axis = 'x'
      direction = 'right'
      placement = 'below'
      scale = @props.cycleScale
    />

  renderFluorAxis: ->
    <Axis
      origin = @state.origin
      axis = 'y'
      direction = 'up'
      placement = 'left'
      scale = @props.fluorScale
    />

module.exports = FluorChart