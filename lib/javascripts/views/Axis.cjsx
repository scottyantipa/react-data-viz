{Text,
Line,
Group}    = require 'react-canvas'
React     = require 'react'
AxisUtils = require '../util/AxisUtils.cjsx'

Axis = React.createClass
  render: ->
    <Group>
      {@renderAxisLine()}
      {@renderLabels()}
    </Group>

  propTypes: AxisUtils.proTypes

  renderAxisLine: ->
    [x0, y0] = @projectDomainValue @props.scale.domain[0]
    [x1, y1] = @projectDomainValue @props.scale.domain[1]
    frame = {
      x0
      y0
      x1
      y1
    }
    <Line
      frame = frame
    />

  # TODO: Great example of why my LinearScale is inferior to d3's.  d3 has much better tick calculation
  # and is smarter about rounding to powers of ten and such.
  renderLabels: ->
    _.map @props.scale.ticks(50), (tick, index) =>
      [left, top] = @projectDomainValue tick
      width = 200
      style = _.extend {left, top, width}, (@props.textStyle ? AxisUtils.defaultTextStyle())

      <Text
        style = style
        key   = index
      >
        {tick.toString()}
      </Text>

  projectDomainValue: (tick) ->
    {axis, direction, placement, origin} = @props
    projected = @props.scale.map tick

    left =
      switch axis
        when 'x'
          switch direction
            when 'right' then projected + origin.x
            when 'left' then -projected + origin.x

        when 'y'
          switch placement
            when 'left' then origin.x - AxisUtils.horiz_offset
            when 'right' then origin.x + AxisUtils.horiz_offset

    top =
      switch axis
        when 'y'
          switch direction
            when 'down' then projected + origin.y # drawing in positive direction
            when 'up' then -projected + origin.y
        when 'x'
          switch placement
            when 'above' then origin.y - AxisUtils.vert_offset
            when 'below' then origin.y + AxisUtils.vert_offset

    [left, top]

module.exports = Axis