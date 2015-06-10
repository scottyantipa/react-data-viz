dataManager = require './dataManager.coffee'
React       = require 'react'
ReactCanvas = require 'react-canvas'
OrdinalAxis = require '../javascripts/views/OrdinalAxis.cjsx'
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
    <OrdinalAxis
      origin    = @ORIGIN
      textStyle = @axisLabelStyle()
      vertical  = false
      scale     = @props.columnScale
    />

  renderRowLabels: ->
    <OrdinalAxis
      textStyle = @axisLabelStyle()
      origin    = @ORIGIN
      vertical  = true
      scale     = @props.rowScale
    />

  axisLabelStyle: ->
    lineHeight: 20
    height: 20
    fontSize: 12

module.exports = Plate