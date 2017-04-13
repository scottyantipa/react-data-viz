_ = require 'underscore'
{Text,
Line,
Group} = require 'react-canvas'
React = require 'react'

###
Renders the axis for a chart.  See propTypes for description
of how to render x or y axis, place labels, etc.
###
Axis = React.createClass

  vert_offset:  10 # helper for rendering x axis labels

  render: ->
    <Group>
      {@renderLabels()}
      {
        if @props.showAxisLine then @renderAxisLine()
      }
    </Group>

  propTypes:
    axis:            React.PropTypes.string.isRequired # 'x' or 'y'
    direction:       React.PropTypes.string.isRequired # 'left', 'right', 'up', 'down'
    placement:       React.PropTypes.string.isRequired # 'above', 'below', 'left', 'right'
    scale:           React.PropTypes.object.isRequired
    offset:          React.PropTypes.number # number in [0,1] describes where to place the whole axis (0 is at origin, 1 is opposite side)
    otherAxisLength: React.PropTypes.number # e.g. length of x axis if this is the y axis
    origin:          React.PropTypes.object
    textStyle:       React.PropTypes.object
    showAxisLine:    React.PropTypes.bool
    axisLineStyle:   React.PropTypes.object
    labelForTick:    React.PropTypes.func
    thickness:       React.PropTypes.number # y axis width, x axis height

  getDefaultProps: ->
    origin: {x: 0, y: 0}
    showAxisLine: true
    thickness: 100
    textStyle:
      lineHeight: 20
      height:     20
      fontSize:   12
    offset:       0
    otherAxisLength: 0
    axisLineStyle: {} # use current ctx styles
    labelForTick: (tick) -> tick.toString() # e.g. if you want an epoch displayed as a proper time format

  getInitialState: ->
    textAlign =
      if @props.axis is 'y'
        if @props.placement is 'left'
          'right'
        else
          'left'
      else
        'left'

    {textAlign}

  renderAxisLine: ->
    [x0, y0] = @projectDomainValue @props.scale.domain[0]
    [x1, y1] = @projectDomainValue _.last(@props.scale.domain)
    frame = {x0,y0,x1,y1}
    <Line
      frame = frame
      style = @props.axisLineStyle
    />


  renderLabels: ->
    [offsetLeft, offsetTop] = @getLabelOffset()
    baseTextStyle = _.clone @props.textStyle
    baseTextStyle.textAlign ?= @state.textAlign
    _.map @props.scale.ticks(50), (tick, index) =>
      [left, top] = @projectDomainValue tick
      # HACK -- need to measure text for x axis
      width = if @props.axis is 'y' then @props.thickness else 100
      left  += offsetLeft
      top   += offsetTop
      style = _.extend {left, top, width}, baseTextStyle

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
    {axis, direction, placement, origin, scale} = @props
    projected = scale.map tick

    left =
      switch axis
        when 'x'
          switch direction
            when 'right' then projected + origin.x
            when 'left' then -projected + origin.x

        when 'y'
          origin.x + @props.otherAxisLength * @props.offset

    top =
      switch axis
        when 'y'
          switch direction
            when 'down' then projected + origin.y # drawing in positive direction
            when 'up' then -projected + origin.y
        when 'x'
          origin.y - @props.otherAxisLength * @props.offset

    [left, top]

  getLabelOffset: ->
    {axis, direction, placement, origin} = @props

    left =
      switch axis
        when 'x'
          0
        when 'y'
          switch placement
            when 'left' then -@props.thickness - 15
            when 'right' then 15

    top =
      switch axis
        when 'y'
          0
        when 'x'
          switch placement
            when 'above' then 2 * -@vert_offset
            when 'below' then @vert_offset

    [left, top]


  axisNameFontStyle: ->
    lineHeight: 30
    height:     30
    fontSize:   13

module.exports = Axis
