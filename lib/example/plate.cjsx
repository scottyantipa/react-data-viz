dataManager = require './dataManager.coffee'
React       = require 'react'
ReactCanvas = require 'react-canvas'
{Surface,
Group,
Point,
Text}       = ReactCanvas


###
Renders a plate given the number of rows/columns
###
Plate = React.createClass
  COL_LABEL_AXIS_HEIGHT: 30
  ROW_LABEL_AXIS_WIDTH: 30

  render: ->
    origin    = @getOrigin()
    axisTextStyle = @axisLabelStyle()

    <Surface
      top    = 0
      left   = 0
      width  = @state.width
      height = @state.height
    >
      <Wells
        origin      = origin
        rowScale    = @props.rowScale
        columnScale = @props.columnScale
      />

      <ColumnHeaders
        origin      = origin
        columnScale = @props.columnScale
        textStyle   = axisTextStyle
      />

      <RowHeaders
        origin = origin
        rowScale = @props.rowScale
        textStyle   = axisTextStyle
      />

    </Surface>

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

ColumnHeaders = React.createClass
  displayName: 'ColumnHeaders'

  render: ->
    <Group>
      {@renderColumnLabels()}
    </Group>

  renderColumnLabels: ->
    _.map @props.columnScale.domain, (column) =>
      left  = @props.columnScale.map(column) + @props.origin.x - 4 # substract radius
      top   = 0
      width = 100 # TODO: measureText
      style = _.extend {left, top, width}, @props.textStyle

      <Text style = style>
        {column.toString()}
      </Text>


RowHeaders = React.createClass
  displayName: 'RowHeaders'

  render: ->
    <Group>
      {@renderRowLabels()}
    </Group>

  renderRowLabels: ->
    _.map @props.rowScale.domain, (row) =>
      top = @props.rowScale.map(row) + @props.origin.y - 8
      left = 0
      width = 100 # TODO: measuretext
      style = _.extend {left, top, width}, @props.textStyle

      <Text style = style>
        {row.toString()}
      </Text>

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