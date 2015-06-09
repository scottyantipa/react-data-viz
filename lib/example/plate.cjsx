dataManager = require './dataManager.coffee'
React       = require 'react'
ReactCanvas = require 'react-canvas'
{Surface,
Group,
Circle,
Point,
FontFace,
Layer}      = ReactCanvas


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
        radius = 5
        frame =
          x: columnProjection
          y: rowProjection
          width: radius + 5
          height: radius + 5
        <Point
          radius = radius
          frame = frame
        />

module.exports = Plate