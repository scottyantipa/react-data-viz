{Text,
Group} = require 'react-canvas'
React  = require 'react'
AxisUtils = require '../util/AxisUtils.cjsx'

###
Renders an axis with an Ordinal domain
Can be vertical or horizontal, given props.vertical bool
###
OrdinalAxis = React.createClass
  render: ->
    <Group>
      {@renderLabels()}
    </Group>

  displayName: 'OrdinalAxis'

  propTypes: AxisUtils.propTypes

  getDefaultProps: -> AxisUtils.defaultProps

  renderLabels: ->
    _.map @props.scale.domain, (tick, index) =>
      scaled = @props.scale.map tick

      # Positioning is super hacky right now because
      # I dont know how react-canvas supports positioning
      # the entire <Group> So right now each axis and axis label has to be aware
      # of where it needs to render itself in relation to the origin
      left =
        if @props.vertical
          if @props.left
            0
          else
            30
        else
          scaled + @props.origin.x - 3 # so text is centered-ish
      top =
        if @props.vertical
          scaled + @props.origin.y - 5 # so text is centered-ish
        else
          if @props.above
            @props.origin.y - 25
          else
            @props.origin.y

      width = 200  # TODO: measureText
      style = _.extend {left, top, width}, (@props.textStyle ? @defaultTextStyle())
      <Text
        style = style
        key   = index
      >
        {tick.toString()}
      </Text>

  defaultTextStyle: ->
    lineHeight: 20
    height: 20
    fontSize: 12

module.exports = OrdinalAxis