Axis = require './Axis.cjsx'

TimeAxis = React.createClass

  render: ->
    {axisName, scale, axis, placement, direction, origin, textStyle, axisLineStyle} = @props
    <Axis
      axisName      = axisName
      origin        = origin
      labelForTick  = @labelForTick
      scale         = scale
      axis          = axis
      placement     = placement
      direction     = direction
      textStyle     = textStyle
      axisLineStyle = axisLineStyle
    />

  displayName: 'TimeAxis'

  componentWillReceiveProps: (newProps) ->
    return if _.isEqual newProps.scale, @props.scale
    @setState @getTimeFormat()

  getInitialState: ->
    @getTimeFormat()

  getTimeFormat: ->
    step = @props.scale.getStep() # miliseconds as a power of 10 between each domain tick
    [timeFormat, timeLabel] =
      if step < 10 * (minute = 1000 * 60)
        ['ss', 's']
      else if step < 5 * (hour = minute * 60)
        ['mm', 'm']
      else if step < 2 * (day = hour * 24)
        ['hh', 'h']
      else if step < (month = day * 30)
        ['DD', 'd']
      else if step < (year = month * 12)
        ['MMMM', '']
      else
        ['ss', 's']

    {timeFormat, timeLabel}

  # Convert epoch -> nicely formatted time string using momentjs
  labelForTick: (epoch) ->
    time =
      moment epoch
        .format @state.timeFormat
    "#{time}#{@state.timeLabel}"

module.exports = TimeAxis

