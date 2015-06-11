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
    [x1, y1] = @projectDomainValue _.last(@props.scale.domain)
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
      [offsetLeft, offsetTop] = @offsetLabelForTick tick
      left += offsetLeft
      top += offsetTop
      width = 200
      style = _.extend {left, top, width}, (@props.textStyle ? AxisUtils.defaultTextStyle())

      <Text
        style = style
        key   = index
      >
        {tick.toString()}
      </Text>

  ###
  Given a value in the domain of the scale, project it to
  pixel values based on the orientation of this axis (x,y) and direction
  (e.g. 'left', 'right',...)
  ###
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
          origin.x

    top =
      switch axis
        when 'y'
          switch direction
            when 'down' then projected + origin.y # drawing in positive direction
            when 'up' then -projected + origin.y
        when 'x'
          origin.y

    [left, top]

  offsetLabelForTick: (tick) ->
    {axis, direction, placement, origin} = @props

    left =
      switch axis
        when 'x'
          switch direction
            when 'right' then origin.x
            when 'left' then -origin.x

        when 'y'
          switch placement
            when 'left' then -AxisUtils.horiz_offset
            when 'right' then AxisUtils.horiz_offset

    top =
      switch axis
        when 'y'
          switch direction
            when 'down' then origin.y
            when 'up' then 0 #-origin.y
        when 'x'
          switch placement
            when 'above' then -AxisUtils.vert_offset
            when 'below' then AxisUtils.vert_offset

    [left, top]


module.exports = Axis