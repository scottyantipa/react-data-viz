dataManager = require './dataManager.coffee'
React       = require 'react'
ReactCanvas = require 'react-canvas'
{Surface,
Group,
Circle,
Point,
FontFace,
Text,
Layer}      = ReactCanvas


Plate = React.createClass
  render: ->
    <Surface
      top    = 0
      left   = 0
      width  = window.innerWidth
      height = window.innerHeight
    >
      <Text style={@textStyle()}>test text</Text>
    </Surface>

  textStyle: ->
    top:         20
    left:        20
    height:      20
    width:       window.innerWidth
    lineHeight:  20
    fontSize:    12

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
        columnProjection = @props.columnScale.map column
        key = dataManager.keyForWell row, column
        isSelected = key is @props.selectedWellKey
        continue if @props.drawSelected and not isSelected

        <Point
          radius = 5
        />

module.exports = Plate