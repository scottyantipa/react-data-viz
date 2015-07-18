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

  POSSIBLE_GRAINS: ["hour", "day" ,"month","year"]

  PIXELS_BETWEEN_HASHES:  12 # minimal padding between every vert line in the time axis
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
        opacity: .2

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
      ticks = @allTicksOnAxisForGrain grain, @props.scale
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
    Figure out the truncationIndex for each group.  This is the level to which
    their label needs to be abbreviated (like "January" --> "Jan" --> "J" --> "").  All ticks in a
    group  will be truncated to the same level of abbreviation, for example... if September needs to be written as
    just "Sep", but "March" can fit fine as it is, we still chop down "March" to "Mar" for consistency.)
    ###
    for tickGroup, tickIndex in tickGroups
      {ticks} = tickGroup

      dontDrawGroup = ->
        tickGroup.dontDrawLabels = true

      maxWidth = @props.scale.dy / ticks.length # max amt of possible space for each tick label
      truncateIndex = largestTruncation = 0 # the level to which we will abreviate each lable in group
      widthOfLargest = 0

      if maxWidth < 10 # dont draw a label in less than 10px width
        dontDrawGroup()
        continue

      # Get the font size, then figure out the ratio
      # to the regular Canvas font size (because getLabelWidth uses standard font size)
      fontSize = @FONT_LARGEST_TIME_AXIS # we dont yet know, so be conservative
      fontRatio = fontSize / 12 # standard size
      for tick, tickIndex in ticks
        if tickIndex is @POSSIBLE_GRAINS.length # At least the outermost row must not be truncated
          text = @formatTimeAxisLabel tick, 0
          textWidth = fontRatio * @getTextMetrics(text, fontSize).lines[0].width
        else
          text = @formatTimeAxisLabel tick, truncateIndex
          while (textWidth = fontRatio * @getTextMetrics(text, fontSize).lines[0].width) > (maxWidth * .7)
            truncateIndex++
            text = @formatTimeAxisLabel tick, truncateIndex
        if textWidth > widthOfLargest then widthOfLargest = textWidth
        if truncateIndex > largestTruncation then largestTruncation = truncateIndex

      # Remove tick group if they can't fit
      if widthOfLargest is 0
        dontDrawGroup()
      else
        tickGroup.truncateIndex = largestTruncation
        tickGroup.widthOfLargest = widthOfLargest

    # Remove the tick groups that are too dense to draw
    while tickGroups[0].dontDrawLabels and tickGroups[0].dontDrawHashes
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
      {ticks, row, numRows, truncateIndex, grain, dontDrawLabels} = tickGroup
      continue if dontDrawLabels or (groupIndex is tickGroups.length - 1)

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
    n = 1 # will represent the number of ticks to not label in order to fit them
    while outerMostTickGroup.widthOfLargest * (outerMostTickGroup.ticks.length / n) > @props.scale.dy * .7 # some padding
      n++

    # Now we need to pluck a bunch of tick marks out so that there are gaps
    # between each tick mark that we draw. That gap should be n tick marks wide.
    numberSkippedInARow = 0
    outerTicksToDraw = [] # will eventually be added to axisLabels
    {row, grain} = outerMostTickGroup
    fontSize = @getFontSize row, tickGroups.length
    fontRatio = fontSize / 12 # standard size
    for tick, index in outerMostTickGroup.ticks
      if numberSkippedInARow < n and n isnt 1 and index isnt 0
        # we haven't made n ticks invisible yet, so dont draw this one
        numberSkippedInARow++
      else
        numberSkippedInARow = 0 # need to skip the next n ticks since we're drawing this one
        @addHashMarkFromTick tick, hashByKey, @props.scale, true
        text = @formatTimeAxisLabel tick, outerMostTickGroup.truncateIndex
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
  allTicksOnAxisForGrain: (grain, timeScale) ->
    {domain} = timeScale
    [ startEpoch, endEpoch ] = domain
    [ startDate, endDate ] = [ new Date(domain[0]), new Date(domain[1]) ]

    ticks = [] # the array to populate with all of the time axis tick marks
    increment = # a function that increments a single date grain
      switch grain

        when "hour"
          if startDate.getSeconds() isnt 0
            startDate.setHours startDate.getHours() + 1
            startDate.setSeconds 0
          (tickDate) =>
            tickDate.setHours tickDate.getHours() + 1

        when "day"
          (tickDate) =>
            tickDate.setDate tickDate.getDate() + 1

        when "month"
          # start with the first full month, unless we have less than a month of data
          isOneMonth = startDate.getMonth() is endDate.getMonth() and startDate.getFullYear() is endDate.getFullYear()
          if startDate.getDate() > 15 and not isOneMonth
            startDate.setMonth startDate.getMonth() + 1
            startDate.setDate 1
          (tickDate) =>
            tickDate.setMonth tickDate.getMonth() + 1
            tickDate.setDate 1

        when "year"
          # start with the first full year, unless we have one year of data
          isOneYear = startDate.getFullYear() is endDate.getFullYear()
          if not isOneYear and endDate.getMonth() isnt 0 # jan
            startDate.setFullYear startDate.getFullYear() + 1
            startDate.setMonth 0
            startDate.setDate 1
          (tickDate) =>
            tickDate.setFullYear tickDate.getFullYear() + 1
            tickDate.setMonth 0 # safegaurd, always want first month of year
            tickDate.setDate 1
        else
          break

    # Pushes each consecutive grain into an array (Jan, Feb, March...)
    numTicks = 0
    while startDate.getTime() <= endEpoch
      newTickDate = new Date(startDate.getTime()) # create a new one to store because we increment the original
      ticks.push
        date: newTickDate
        grain: grain
      numTicks++
      # Never a need to show 500 axis marks.  This enhances performance.
      return false if numTicks >= 500
      increment startDate
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

  getX: (shape, timeScale = @props.scale) ->
    isLabel = @typeOfShapeFromKey(shape.key) is 'tick'
    if isLabel
      {row, numRows, date, grain, width} = shape
      epoch = date.getTime()
      if row is numRows
        timeScale.map(epoch) + 5 # some padding
      else # middle align the text
        middleEpoch = DateUtils.midPointOfGrain(date, grain).getTime()
        centerInPixels = timeScale.map middleEpoch
        centerInPixels - width/2
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
    {year, month, week, day} = dateObj = DateUtils.timeToDateObj date.getTime()

    getMonth = ->
      standardMonth = DateUtils.MONTH_INFOS[month].name
      switch truncateIndex
        when 0
          DateUtils.MONTH_INFOS[month].longName
        when 1
          standardMonth
        when 2
          standardMonth[0]
        else
          # If it's the outermost row, then you have to show something so show first letter
          if row is numRows then standardMonth[0] else ""

    getDay = ->
      switch truncateIndex
        when 0
          moment(date).format "Do" # Formats 31 as 31st
        when 1
          dateObj[grain]
        else
          ""
    getHour = ->
      switch truncateIndex
        when 0
          dateObj[grain] + 'hr'
        when 1
          dateObj[grain]
        else
          ""

    val =
      switch grain
        when "month"
          getMonth()
        when "day"
          getDay()
        when "hour"
          getHour()
        else # the default formatting
          switch truncateIndex
            when 0
              dateObj[grain]
            else
              # this is the smallest text we can show for that tick
              if row is numRows then dateObj[grain] else ""
    val.toString()

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

