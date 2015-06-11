dataManager = require './dataManager.coffee'
React       = require 'react'
ReactCanvas = require 'react-canvas'
OrdinalAxis = require '../javascripts/views/OrdinalAxis.cjsx'
Axis        = require '../javascripts/views/Axis.cjsx'
Wells       = require './Wells.cjsx'
{Surface,
Group,
Text,
Layer,
Point,
Text}       = ReactCanvas

###
Renders a plate given the number of rows/columns
###
Plate = React.createClass
  ORIGIN: {x: 30, y: 30} # will need to be parameterized

  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = {@props.columnScale.range[1] + @ORIGIN.x}
      height = {@props.rowScale.range[1] + @ORIGIN.y}
    >
      {@renderColumnLabels()}
      {@renderRowLabels()}
      {@renderWells()}
    </Surface>

  renderWells: ->
    <Wells
      origin      = @ORIGIN
      rowScale    = @props.rowScale
      columnScale = @props.columnScale
    />

  # This should eventually be it's own surface
  renderColumnLabels: ->
    <Axis
      origin    = @ORIGIN
      scale     = @props.columnScale
      axis      = 'x'
      placement = 'above'
      direction = 'right'
    />

  renderRowLabels: ->
    <Axis
      origin    = @ORIGIN
      scale     = @props.rowScale
      axis      = 'y'
      placement = 'left'
      direction = 'down'
    />

  axisLabelStyle: ->
    lineHeight: 20
    height: 20
    fontSize: 12

module.exports = Plate