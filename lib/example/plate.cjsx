React       = require 'react'
dataManager = require './dataManager.coffee'

{Surface,
Group,
Circle,
Text,
FontFace,
Layer}      = require 'react-canvas'

Plate = React.createClass

  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = window.innerWidth
      height = window.innerHeight
    >
      <Wells
        width       = window.innerWidth
        height      = window.innerHeight
        top         = 0
        left        = 0
        rowScale    = @props.rowScale
        columnScale = @props.columnScale
      />
    </Surface>

  renderText: ->
    <Text
      style = @textStyle()
    >
      Some text here for you
    </Text>

  textStyle: ->
    top:         20
    left:        20
    height:      20
    width:       window.innerWidth
    lineHeight:  20
    fontSize:    12

Wells = React.createClass

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
        columnProjection = @props.columnScale.map column
        key = dataManager.keyForWell row, column
        isSelected = key is @props.selectedWellKey
        continue if @props.drawSelected and not isSelected
        textStyle = @textStyle()
        textStyle.top = rowProjection
        textStyle.left = columnProjection
        <Text
          style = textStyle
        >
          {"#{row}-#{column}"}
        </Text>

  textStyle: ->
    height: 20
    width: 100
    lineHeight: 20
    fontSize: 12

module.exports = Plate