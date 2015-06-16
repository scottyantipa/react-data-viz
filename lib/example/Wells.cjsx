{Group,
Point} = require 'react-canvas'
React  = require 'react'

###
Renders a grid of circles representing a plate
###
Wells = React.createClass
  displayName: 'Wells'

  render: ->
    <Group>
      {@renderWells()}
    </Group>

  renderWells: ->
    maxRadius = @props.rowScale.m / 3
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

module.exports = Wells