React = require 'react'
createReactClass = require 'create-react-class'
{Group,
Point} = require 'react-canvas'

###
Renders a grid of circles representing a plate
###
Wells = createReactClass
  displayName: 'Wells'
  wellStyle:
    opacity:     .5
    fillStyle:   'blue'
    strokeStyle: 'blue'
    lineWidth:   2
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
        columnProjection = @props.columnScale.map column
        radius = 5
        frame =
          x: columnProjection + @props.origin.x # ugly, the parent should figure out how to set tx/ty on this class
          y: rowProjection + @props.origin.y
          width: radius + 5
          height: radius + 5
        <Point
          radius = radius
          frame  = frame
          style  = @wellStyle
        />

module.exports = Wells
