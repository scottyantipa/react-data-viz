{Text,
Group} = require 'react-canvas'
React  = require 'react'

###
Renders an axis with an Ordinal domain
Can be vertical or horizontal, given props.vertical bool
###
OrdinalAxis = React.createClass
  render: ->
    <Group style={@props.groupStyle}>
      {@renderLabels()}
    </Group>

  displayName: 'OrdinalAxis'

  propTypes:
    vertical:     React.PropTypes.bool.isRequired
    scale:        React.PropTypes.object.isRequired
    origin:       React.PropTypes.object # assumed to be [0,0]
    textStyle:    React.PropTypes.object

  getDefaultProps: ->
    origin:
      x: 0
      y: 0
    textStyle:
      lineHeight: 20
      height:     20
      fontSize:   12

  renderLabels: ->
    _.map @props.scale.domain, (tick, index) =>
      scaled = @props.scale.map tick
      left =
        if @props.vertical
          0
        else
          scaled + @props.origin.x - 3 # so text is centered-ish
      top =
        if @props.vertical
          scaled + @props.origin.y - 5 # so text is centered-ish
        else
          0
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