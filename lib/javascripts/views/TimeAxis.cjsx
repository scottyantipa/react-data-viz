Axis = require './Axis.cjsx'

TimeAxis = React.createClass

  render: ->
    {axisName, scale, axis, placement, direction, origin, textStyle} = @props
    <Axis
      axisName     = axisName
      origin       = origin
      labelForTick = @labelForTickf
      scale        = scale
      axis         = axis
      placement    = placement
      direction    = direction
      textStyle    = textStyle
    />

  displayName: 'TimeAxis'

  getInitialState: ->
    step = @props.scale.getStep() # miliseconds as a power of 10 between each domain tick
    [timeFormat, timeLabel] =
      if step < (minute = 1000 * 60)
        ['ss', 's']
      else if step < (hour = minute * 60)
        ['mm', 'm']
      else if step < (day = hour * 24)
        ['hh', 'h']
      else if step < (month = day * 30)
        ['DD', 'd']
      else if step < (year = month * 12)
        ['MMMM', '']

    {timeFormat, timeLabel}

  # Convert epoch -> nicely formatted time string using momentjs
  labelForTick: (epoch) ->
    time =
      moment epoch
        .format @state.timeFormat
    "#{time}#{@state.timeLabel}"

module.exports = TimeAxis

