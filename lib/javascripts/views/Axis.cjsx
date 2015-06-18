{Text,
Line,
Group}    = ReactCanvas

###
Renders the axis for a chart.  See propTypes for description
of how to render x or y axis, place labels, etc.
###
Axis = React.createClass
  render: ->
    <Group>
      {@renderLabels()}
      {
        if @props.showAxisLine then @renderAxisLine()
      }
    </Group>

  propTypes:
    axis:         React.PropTypes.string.isRequired # 'x' or 'y'
    direction:    React.PropTypes.string.isRequired # 'left', 'right', 'up', 'down'
    placement:    React.PropTypes.string.isRequired # 'above', 'below', 'left', 'right'
    scale:        React.PropTypes.object.isRequired
    origin:       React.PropTypes.object # assumed to be [0,0]
    textStyle:    React.PropTypes.object
    showAxisLine: React.PropTypes.bool
    labelForTick: React.PropTypes.func

  getDefaultProps: ->
    origin:       {x: 0, y: 0}
    showAxisLine: true
    labelForTick: (tick) -> tick.toString() # e.g. if you want an epoch displayed as a proper time format


  # how much to offset axis labels by so they dont render on the axis
  # This is currently not parameterized and needs to change
  horiz_offset: 30
  vert_offset:  20

  renderAxisLine: ->
    [x0, y0] = @projectDomainValue @props.scale.domain[0]
    [x1, y1] = @projectDomainValue _.last(@props.scale.domain)
    frame = {x0,y0,x1,y1}
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
      style = _.extend {left, top, width}, (@props.textStyle ? @defaultTextStyle())
      <Text
        style = style
        key   = index
      >
        {
          @props.labelForTick tick
        }
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
          0
        when 'y'
          switch placement
            when 'left' then -@horiz_offset
            when 'right' then @horiz_offset

    top =
      switch axis
        when 'y'
          0
        when 'x'
          switch placement
            when 'above' then -@vert_offset
            when 'below' then @vert_offset

    [left, top]


  defaultTextStyle: ->
    lineHeight: 20
    height:     20
    fontSize:   12

module.exports = Axis