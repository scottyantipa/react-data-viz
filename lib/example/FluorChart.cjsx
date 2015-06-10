React       = require 'react'
{Surface}   = require 'react-canvas'
OrdinalAxis = require '../javascripts/views/OrdinalAxis.cjsx'


###
Renders a qCPR line chart showing Fluorescense vs. Cycle
###
FluorChart = React.createClass
  ORIGIN: {x: 30, y: 30} # will need to be parameterized

  render: ->
    <Surface
      top = 500
      left = 0
      width = {@props.cycleScale.range[1] + @ORIGIN.x}
      height = 500
    >
      {@renderCycleAxis()}
    </Surface>

  renderCycleAxis: ->
    <OrdinalAxis
      origin = @ORIGIN
      vertical = false
      scale = @props.cycleScale
    />

module.exports = FluorChart