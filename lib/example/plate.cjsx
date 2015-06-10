dataManager = require './dataManager.coffee'
React       = require 'react'
ReactCanvas = require 'react-canvas'
OrdinalAxis = require '../javascripts/views/OrdinalAxis.cjsx'
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
  COL_LABEL_AXIS_HEIGHT: 30
  ROW_LABEL_AXIS_WIDTH: 30

  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = @state.width
      height = @state.height
    >

    {@renderColumnLabels()}
    {@renderRowLabels()}
    {@renderWells()}

    </Surface>

  renderWells: ->
    <Wells
      origin      = @getOrigin()
      rowScale    = @props.rowScale
      columnScale = @props.columnScale
    />

  # This should eventually be it's own surface
  renderColumnLabels: ->
    <OrdinalAxis
      origin    = @getOrigin()
      textStyle = @axisLabelStyle()
      vertical  = false
      scale     = @props.columnScale
    />

  renderRowLabels: ->
    <OrdinalAxis
      textStyle = @axisLabelStyle()
      origin    = @getOrigin()
      vertical  = true
      scale     = @props.rowScale
    />

  getOrigin: ->
    x: @ROW_LABEL_AXIS_WIDTH
    y: @COL_LABEL_AXIS_HEIGHT

  getInitialState: ->
    @stateFromProps @props

  stateFromProps: (props) ->
    height: props.rowScale.range[1] + @COL_LABEL_AXIS_HEIGHT
    width:  props.columnScale.range[1] + @ROW_LABEL_AXIS_WIDTH

  componentWillReceiveProps: (newProps) ->
    @setState @stateFromProps(newProps)

  axisLabelStyle: ->
    lineHeight: 20
    height: 20
    fontSize: 12

Wells = React.createClass
  displayName: 'Wells'

  render: ->
    <Group>
      {@renderWells()}
    </Group>

  renderWells: ->
    maxRadius = @props.rowScale.k / 3
    minRadius = 6
    if maxRadius < minRadius then maxRadius = minRadius + 2

    for row in @props.rowScale.domain
      rowProjection = @props.rowScale.map row
      for column in @props.columnScale.domain

        # TODO: implement selection
        # key = dataManager.keyForWell row, column
        # isSelected = key is @props.selectedWellKey
        # continue if @props.drawSelected and not isSelected

        columnProjection = @props.columnScale.map column
        radius = 5
        frame =
          x: columnProjection + @props.origin.x # ugly, the parent should figure out how to set tx/ty on this class
          y: rowProjection + @props.origin.y
          width: radius + 5
          height: radius + 5
        <Point
          radius = radius
          frame = frame
        />

module.exports = Plate