React = require 'react'
{Surface, Text, Line, Group} = require 'react-canvas'

###
A little component that has state which can be changed through pressing some buttons
Purpose is to show that react-canvas does the graph diffing properly and updates the canvas
###
StatefulSmokeTest = React.createClass

  render: ->
    textStyle = _.extend({
        left: 0
        top: 0
      }, @defaultFontStyling())

    <div
      className = '.stateful-smoke-test'
      style = {position: 'absolute', top: 50, left: 50}
    >
      <div>This component stores numLines as state.  It should render each line with a number next to it.  Toggle numLines below.</div>
      {@renderButtons()}
      <Surface
        top    = 0
        left   = 0
        width  = 200
        height = 200
      >
        <Group>
          {@renderLines()}
        </Group>
      </Surface>
    </div>

  getInitialState: ->
    numLines: 3

  renderLines: ->
    _.map [0...@state.numLines], (index) =>
      y = index * 30 + 10
      textStyle = _.extend({
        top: y - 10
        left: 0
        }, @defaultFontStyling())
      frame =
        x0: 15
        y0: y
        x1: 100
        y1: y

      <Group key=index>
        <Line
          frame = frame
        />
        <Text
          style=textStyle
        >
          {index.toString()}
        </Text>
      </Group>

  renderButtons: ->
    <div>
      <button
        onClick = { => @setState numLines: 5}
      >
        5 lines
      </button>

      <button
        onClick = { => @setState numLines: 3}
      >
        3 lines
      </button>

    </div>

  defaultFontStyling: ->
    width: 100
    fontSize: 12
    lineHeight: 20
    height: 20

module.exports = StatefulSmokeTest
