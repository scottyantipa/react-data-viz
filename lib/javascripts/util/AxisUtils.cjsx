React = require 'react'


###
Common methods for views that render an Axis (e.g. LinearAxis)
###
AxisUtils =

  propTypes:
    axis:         React.PropTypes.bool.isRequired # 'x' or 'y'
    direction:    React.PropTypes.string.isRequired # 'left', 'right', 'up', 'down'
    placement:    React.PropTypes.string.isRequired # 'above', 'below', 'left', 'right'
    scale:        React.PropTypes.object.isRequired
    origin:       React.PropTypes.object # assumed to be [0,0]
    textStyle:    React.PropTypes.object

  defaultProps:
    origin:
      x: 0
      y: 0
    textStyle:
      lineHeight: 20
      height:     20
      fontSize:   12

  # how much to offset axis labels by so they dont render on the axis
  # This is currently not parameterized and needs to change
  horiz_offset: 30
  vert_offset:  20

  defaultTextStyle: ->
    lineHeight: 20
    height:     20
    fontSize:   12

module.exports = AxisUtils