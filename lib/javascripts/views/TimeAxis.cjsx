Axis      = require './Axis.cjsx'
DateUtils = require '../util/DateUtils.coffee'
{measureText,
Line,
Group,
Text,
FontFace} = ReactCanvas

###
Renders a time axis with multiple levels of granularity.  For example,
If days are the smallest grain we can show, it will also render months and years.
"Ticks" denote a position on the axis.  A "Hash" is a vertical line marking the axis.
###
TimeAxis = React.createClass
  displayName: 'TimeAxis'

  POSSIBLE_GRAINS: ["second", "minute", "hour", "day" ,"month","year"]

  PIXELS_BETWEEN_HASHES:  8 # minimal padding between every vert line in the time axis
  LABEL_PADDING:          3 # space between a hash mark and a label
  SMALLEST_HASH_MARK:     15 # shortest length of vert lines in time axis
  FONT_LARGEST_TIME_AXIS: 13

  FONT_FACE: FontFace.Default(600)
  KEY_DIVIDER: "::"

  render: ->
    {axisLabels, axisHashes} = @calcShapes()

    <Group>
      {@renderLabels axisLabels}
      {@renderHashes axisHashes}
      {@renderAxisLine()}
    </Group>


  renderLabels: (labels) ->
    {origin} = @props
    _.map labels, (label, index) =>
      {x, y, text, fontSize, width} = label
      baseTextStyle = _.clone @props.textStyle
      style = _.extend baseTextStyle,
        left: x + origin.x
        top: y + origin.y
        fontSize: fontSize
        width: width

      <Text
        style = style
        key   = index
      >
        {text}
      </Text>

  renderHashes: (hash) ->
    {origin} = @props
    _.map hash, (hash, index) =>
      {x, y0, y1}  = hash
      x += origin.x
      frame =
        x0: x
        y0: origin.y + y0
        x1: x
        y1: origin.y + y1

      style = _.extend @props.axisLineStyle,
        opacity: .5
        lineWidth: .5

      <Line
        style = style
        frame = frame
      />


  renderAxisLine: ->
    {x,y} = @props.origin

    axisFrame =
      x0: x
      y0: y
      x1: x + @props.scale.range[1]
      y1: y

    <Line
      frame = axisFrame
      style = @props.axisLineStyle
    />


  calcShapes: ->
    numRows = @POSSIBLE_GRAINS.length
    axisLabels = [] # all the labels on the axis
    axisHashes = [] # all the vert lines on the axis

    # Calc basic rows of the axis (year, month, day rows)
    tickGroups = []
    for grain, row in @POSSIBLE_GRAINS
      ticks = @ticksForGrain grain, @props.scale
      continue if not ticks
      group = {ticks, grain}
      tickGroups.push group

    ###
    Create the hash marks (the little vertical lines on the time axis).
    We will draw a hash mark for every tick, however, there will be overlap so we
    only draw one in this case.  For example, on January, 1, 2001, there are three (for year, month, and day)
    ###

    # First, figure out if we even want to draw the hash marks for each of the grains
    # If not, move the rows up (i.e. if showing year-month-day but removing the days, move year and month up
    # a row)
    for tickGroup, i in tickGroups
      continue if i is tickGroups.length - 1 # Have to draw hashes if its the only row
      if tickGroup.ticks.length > (@props.scale.dy / @PIXELS_BETWEEN_HASHES)
        tickGroup.dontDrawHashes = true

    # @y is the total height of the time axis
    # TODO: Store in state, not as instance var
    @y = @hashLengthForRow _.last(tickGroups).row

    for tickGroup in tickGroups
      {ticks, grain, row} = tickGroup
      for tick in ticks
        tick.grain = grain
        tick.key = @formatKeyForTick tick

    ###
    Figure out the truncateIndex for each group.  This is the level to which
    their label needs to be abbreviated (like "January" --> "Jan" --> "J" --> "").  All ticks in a
    group  will be truncated to the same level of abbreviation, for example... if September needs to be written as
    just "Sep", but "March" can fit fine as it is, we still chop down "March" to "Mar" for consistency.)
    ###
    for tickGroup, groupIndex in tickGroups
      {ticks} = tickGroup

      # TODO: the space for each tick is NOT uniform, as we assume here.  The first and last tick can have less space.
      spacePerTick = (@props.scale.dy / ticks.length)
      maxWidth = spacePerTick - 2 * @LABEL_PADDING # max amt of possible space for each tick label
      if maxWidth < 10
        tickGroup.labelsCannotFit = true

      largestTruncation = 0 # the level to which we will abreviate each lable in group
      widthOfLargest    = 0
      fontSize          = @FONT_LARGEST_TIME_AXIS # we dont yet know, so be conservative

      for tick, tickIndex in ticks
        truncateIndex      = -1
        textIsntCollapsed  = true
        textFitsInMaxSpace = false
        while textIsntCollapsed and not textFitsInMaxSpace
          truncateIndex++
          if not text = @formatTimeAxisLabel tick, truncateIndex
            textIsntCollapsed = false
            truncateIndex--
          else
            width = @getTextMetrics(text, fontSize).lines[0].width
            textFitsInMaxSpace = width <= maxWidth

        widthOfLargest    = Math.max width, widthOfLargest
        largestTruncation = Math.max truncateIndex, largestTruncation

      tickGroup.widthOfLargest = widthOfLargest
      tickGroup.truncateIndex  = largestTruncation

    # Remove the tick groups that are too dense to draw.  Make sure to leave at least one group.
    groupsRemoved = 0
    while tickGroups[0].labelsCannotFit and tickGroups[0].dontDrawHashes and groupsRemoved < @POSSIBLE_GRAINS.length
      groupsRemoved++
      tickGroups.splice 0, 1

    tickGroups = tickGroups.slice 0, 3 # we only want a max of three granularities

    # We now know exactly how many groups we will render
    for tickGroup, i in tickGroups
      row = i + 1 # note: not 0 indexed
      numRows = tickGroups.length
      tickGroup.row = row
      tickGroup.numRows = numRows
      for tick in tickGroup.ticks
        tick.row = row
        tick.numRows = numRows

    # Now that we know how much all the ticks must be truncated, we have to actually
    # iterate over them and see which ones we can draw (can have positive width)
    innerTicksToDraw = [] # will eventually be added to axisLabels
    for tickGroup, groupIndex in tickGroups
      {ticks, row, numRows, truncateIndex, grain} = tickGroup
      continue if tickGroup.labelsCannotFit or groupIndex is tickGroups.length - 1 # outermost group is done separately
      fontSize = @getFontSize row, numRows
      for tick, tickIndex in ticks
        {date} = tick
        text = @formatTimeAxisLabel tick, truncateIndex
        continue if not text # we won't display them at all because there's no space
        textWidth = @getTextMetrics(text, fontSize).lines[0].width
        $.extend tick, {text, fontSize, width: textWidth}
        tick = @formatTickLayout tick
        continue if tick.x + textWidth > @props.scale.dy # don't draw it if the label goes over the chart width
        innerTicksToDraw.push tick

    hashByKey = {} # will eventually be added to axisHashes
    i = tickGroups.length
    while i > 0
      tickGroup = tickGroups[i - 1]
      if tickGroup.dontDrawHashes or i is tickGroups.length # outtermost handled separately
        i--
        continue
      for tick, tickIndex in tickGroup.ticks
        @addHashMarkFromTick tick, hashByKey, @props.scale, false
      i--

    # For outer most ticks, figure out how many to skip (if not enough space for all)
    outerMostTickGroup = _.last tickGroups
    numToSkip = 1 # will represent the number of ticks to not label in order to fit them
    largest = outerMostTickGroup.widthOfLargest
    while (largest + 2 * @LABEL_PADDING) * (outerMostTickGroup.ticks.length / numToSkip) > @props.scale.dy * .7 # some padding
      numToSkip++

    # Now we need to pluck a bunch of tick marks out so that there are gaps
    # between each tick mark that we draw. That gap should be n tick marks wide.
    numberSkippedInARow = 0
    outerTicksToDraw = [] # will eventually be added to axisLabels
    {row, grain} = outerMostTickGroup
    fontSize = @getFontSize row, tickGroups.length
    fontRatio = fontSize / 12 # standard size
    for tick, index in outerMostTickGroup.ticks
      if numberSkippedInARow < numToSkip and numToSkip isnt 1 and index isnt 0
        # we haven't made n ticks invisible yet, so dont draw this one
        numberSkippedInARow++
      else
        numberSkippedInARow = 0 # need to skip the next n ticks since we're drawing this one
        @addHashMarkFromTick tick, hashByKey, @props.scale, true
        text = @formatTimeAxisLabel tick, 0 # dont truncate the outermost text
        textWidth = fontRatio * @getTextMetrics(text, fontSize).lines[0].width
        tick = @formatTickLayout(tick)
        $.extend tick, {text, fontSize}
        continue if tick.x + textWidth > @props.scale.dy # don't draw the label if it goes over the edge
        tick.width = textWidth
        outerTicksToDraw.push tick

    # push in our shapes
    axisHashes = (@formatHashMarkLayout(hash) for epoch, hash of hashByKey) # the vert lines
    axisLabels = axisLabels.concat(outerTicksToDraw).concat(innerTicksToDraw)
    {axisHashes, axisLabels}


  # Given a time range, produces a sequence of tick marks at incrementing dates.
  # It only does it for one grain at a time (i.e. "year"). So if you want to show multiple
  # grains, run this function for each grain.
  ticksForGrain: (grain, timeScale) ->
    {domain} = timeScale
    [startEpoch, endEpoch] = domain

    # Always push the first tick. Then push ticks that are rounded to nearest grain.
    ticks = [ # the array to populate with all of the time axis tick marks
      {
        date: new Date startEpoch
        grain
      }
    ]

    # This is the date we will increment
    pointer = DateUtils.roundDateToGrain new Date(startEpoch), grain
    incrementer = DateUtils.incrementerForGrain[grain]
    numTicks = 0
    while (time = pointer.getTime()) <= endEpoch
      if time < startEpoch
        incrementer pointer
        continue
      ticks.push {
        date: new Date time
        grain
      }
      incrementer pointer
      numTicks++
      return false if numTicks >= 500 # Never a need to show 500 axis marks.  This enhances performance.

    ticks


  #--------------------------------------------------------------------------------
  # Styling
  #--------------------------------------------------------------------------------

  getFontSize: (row, numRows) ->
    if row is numRows
      @FONT_LARGEST_TIME_AXIS
    else if row is 1
      @FONT_LARGEST_TIME_AXIS - 4
    else if row is 2
      @FONT_LARGEST_TIME_AXIS - 3
    else
      @FONT_LARGEST_TIME_AXIS

  # The Y length of a hash mark
  hashLengthForRow: (row) ->
    @SMALLEST_HASH_MARK * row

  getX: (shape, timeScale = @props.scale, centerText) ->
    isLabel = @typeOfShapeFromKey(shape.key) is 'tick'
    if isLabel
      {row, numRows, date, grain, width} = shape
      epoch = date.getTime()
      if centerText
        middleEpoch = DateUtils.midPointOfGrain(date, grain).getTime()
        centerInPixels = timeScale.map middleEpoch
        centerInPixels - width/2
      else
        timeScale.map(epoch) + @LABEL_PADDING # some padding
    else
      epoch = shape.date.getTime()
      timeScale.map epoch

  # returns the type of the shape (based on the key). Could be a tick or a hash.
  typeOfShapeFromKey: (key) ->
    parts = key.split @KEY_DIVIDER
    return parts[0]

  # ----------------------------------------------
  # Shape creation
  # ----------------------------------------------

  addHashMarkFromTick: (tick, hashMap, timeScale, shouldOverride = false) ->
    tickHash = $.extend {}, tick
    epoch = tick.date.getTime()
    hashKey = @formatKeyForHashMark tickHash
    return if not shouldOverride and hashMap[epoch] # dont draw if there's already a tick on that spot
    hashMap[epoch] = tickHash # may override a previous one, which is good
    tickHash.key = hashKey
    tickHash.x = timeScale.map tickHash.date.getTime()

  formatTickLayout: (tick) ->
    $.extend tick,
      y: @hashLengthForRow(tick.row) - 13 # kind of hacky to hard code this offset
      x: @getX tick

  # Formats positions for the vert lines on the time axis
  formatHashMarkLayout: (tickHash) ->
    x = @getX tickHash
    $.extend tickHash,
      x: x
      y0: 0
      y1: @hashLengthForRow tickHash.row

  # ----------------------------------------------
  # Text measuring, abbreviation, etc.
  # ----------------------------------------------

  getTextMetrics: (text, fontSize) ->
    measureText(
      text,
      200, # default width.  Still not sure why this has to be passed
      @FONT_FACE,
      fontSize,
      fontSize
    )

  ###
  This formats the labels on the time line axis
  arguments:
    tick:
      Info for the mark on the time axis (the date, the scale -- like "year")
    truncateIndex:
      How much we need to abbreviate the text by (its an integer)
  ###
  formatTimeAxisLabel: (tick, truncateIndex = 0) ->
    {date, grain, row, numRows, isFirstTick} = tick
    dateObj = DateUtils.timeToDateObj date.getTime()

    val =
      if formatter = @formatLabelByGrain[grain]
        formatter truncateIndex, dateObj
      else # the default formatting
        switch truncateIndex
          when 0
            dateObj[grain]
    if val
      val.toString()
    else
      undefined

  # Returns a string or undefined if the label cannot be truncated to that level
  # TODO: Day should display like "Feb 1 2011"
  # TODO: Month should display like "Feb 2011"
  formatLabelByGrain:
    second: (truncateIndex, {second}) ->
      switch truncateIndex
        when 0
          second + 's'
        when 1
          second
    minute: (truncateIndex, {minute}) ->
      switch truncateIndex
        when 0
          minute + 'm' # 7m
        when 1
          minute       # 7
    hour: (truncateIndex, {date}) ->
      switch truncateIndex
        when 0
          moment(date).format 'ha' # 7pm
        when 1
          moment(date).format 'h'  # 7
    day: (truncateIndex, {date}) -> # Takes a Date object for moment to use
      switch truncateIndex
        when 0
          moment(date).format "Do" # Formats 31 as 31st
        when 1
          date.getDate()
    month: (truncateIndex, {date}) ->
      m = moment date
      switch truncateIndex
        when 0
          m.format 'MMMM'    # July
        when 1
          m.format 'MMM'     # Jul
        when 2
          m.format('MMM')[0] # J

  formatKeyForTick: (tick) ->
    [
      "tick"
      tick.grain
      "#{tick.date.getTime()}"
    ].join @KEY_DIVIDER

  formatKeyForHashMark: (hash) ->
    [
      "hash"
      hash.grain
      "#{hash.date.getTime()}"
    ].join @KEY_DIVIDER


module.exports = TimeAxis

