Axis      = require './Axis.cjsx'
DateUtils = require '../util/DateUtils.coffee'
{measureText,
FontFace} = ReactCanvas

TimeAxis = React.createClass
  PIXELS_BETWEEN_TICKS: 12 # minimal padding between every vert line in the time axis
  SMALLEST_HASH_MARK: 14 # shortest length of vert lines in time axis
  FONT_LARGEST_TIME_AXIS: 14
  FONT_FACE: FontFace.Default(600)
  KEY_DIVIDER: "::"

  render: ->

    shapes = @calcShapes()

    {axisName,
    scale,
    axis,
    placement,
    direction,
    origin,
    textStyle,
    offset,
    otherAxisLength,
    showAxisLine,
    axisLineStyle} = @props

    <Axis
      axisName        = axisName
      origin          = origin
      labelForTick    = @labelForTick
      scale           = scale
      axis            = axis
      placement       = placement
      direction       = direction
      textStyle       = textStyle
      offset          = offset
      otherAxisLength = otherAxisLength
      showAxisLine    = showAxisLine
      axisLineStyle   = axisLineStyle
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


  calcShapes: ->
    grainsToDraw = ["day" ,"month","year"] # static for now
    numRows = grainsToDraw.length
    axisLabels = [] # all the labels on the axis
    axisTicks = [] # all the vert lines on the axis

    # Calc basic rows of the axis (year, month, day rows)
    tickGroups = []
    for grain, row in grainsToDraw
      ticks = @allTicksOnAxisForGrain grain, @props.scale
      row = row + 1 # so that the rows start at 1, rather than 0
      group = {ticks, grain, row, numRows}
      tickGroups.push group

    ###
    Create the hash marks (the little vertical lines on the time axis).
    We will draw a hash mark for every tick, however, there will be overlap so we
    only draw one in this case.  For example, on January, 1, 2001, there are three (for year, month, and day)
    ###

    # First, figure out if we even want to draw the hash marks for each of the grains
    # If not, move the rows up (i.e. if showing year-month-day but removing the days, move year and month up
    # a row)
    for tickGroup in tickGroups
      continue if @isOutermostGroup(tickGroup) # Have to draw hashes if its the only row
      if tickGroup.ticks.length > (@props.scale.dy / @PIXELS_BETWEEN_TICKS)
        tickGroup.dontDrawHashes = true
        for otherTickGroup in tickGroups # change numRows and rows for remaining groups
          otherTickGroup.row--
          otherTickGroup.numRows--

    # @y is the total height of the time axis
    @y = @getY _.last(tickGroups).row

    for tickGroup in tickGroups
      {ticks, grain, row, numRows} = tickGroup
      for tick in ticks
        $.extend tick, {row, numRows, grain}
        tick.key = @formatKeyForTick tick

    hashByKey = {} # will eventually be added to axisTicks
    i = tickGroups.length
    while i > 0
      tickGroup = tickGroups[i - 1]
      if tickGroup.dontDrawHashes or @isOutermostGroup(tickGroup) # outtermost handled separately
        i--
        continue
      for tick, tickIndex in tickGroup.ticks
        @addHashMarkFromTick tick, hashByKey, @props.scale, false
      i--

    ###
    Figure out the truncationIndex for each group.  This is the level to which
    their label needs to be abbreviated (like "January" --> "Jan" --> "J" --> "").  All ticks in a
    group  will be truncated to the same level of abbreviation, for example... if September needs to be written as
    just "Sep", but "March" can fit fine as it is, we still chop down "March" to "Mar" for consistency.)
    ###
    for tickGroup in tickGroups
      {row, numRows, ticks} = tickGroup

      dontDrawGroup = ->
        tickGroup.dontDrawLabels = true

      maxWidth = @props.scale.dy / ticks.length # max amt of possible space for each tick label
      truncateIndex = largestTruncation = 0 # the level to which we will abreviate each lable in group
      widthOfLargest = 0

      if maxWidth < 3 and not @isOutermostGroup(tickGroup) # cant draw a label in 2 pix
        dontDrawGroup()
        continue

      # Get the font size, then figure out the ratio
      # to the regular Canvas font size (because getLabelWidth uses standard font size)
      fontSize = @getFontSize row, numRows
      fontRatio = fontSize / 12 # standard size
      for tick, tickIndex in ticks
        if row is numRows # we never truncate the outermost row (which is "year") because we need to show something
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

    # Now that we know how much all the ticks must be truncated, we have to actually
    # iterate over them and see which ones we can draw (can have positive width)
    innerTicksToDraw = [] # will eventually be added to axisLabels
    for tickGroup, groupIndex in tickGroups
      {ticks, row, numRows, truncateIndex, grain, dontDrawLabels} = tickGroup
      fontSize = @getFontSize row, numRows

      continue if row is numRows or dontDrawLabels

      for tick, tickIndex in ticks
        {date} = tick
        text = @formatTimeAxisLabel tick, truncateIndex
        continue if not text # we won't display them at all because there's no space
        textWidth = @getTextMetrics(text, fontSize).lines[0].width
        $.extend tick, {text, fontSize, textWidth}
        tick = @formatTickLayout tick
        continue if tick.x + textWidth > @props.scale.dy # don't draw it if the label goes over the chart width
        innerTicksToDraw.push tick

    # For outer most ticks, figure out how many to skip (if not enough space for all)
    outerMostTickGroup = _.last tickGroups
    n = 1 # will represent the number of ticks to not label in order to fit them
    while outerMostTickGroup.widthOfLargest * (outerMostTickGroup.ticks.length / n) > @props.scale.dy * .7 # some padding
      n++

    # Now we need to pluck a bunch of tick marks out so that there are gaps
    # between each tick mark that we draw. That gap should be n tick marks wide.
    numberSkippedInARow = 0
    outerTicksToDraw = [] # will eventually be added to axisLabels
    {row, numRows, grain} = outerMostTickGroup
    fontSize = @getFontSize row, numRows
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
        outerTicksToDraw.push tick

    # push in our shapes
    axisTicks = (@formatHashMarkLayout(hash) for epoch, hash of hashByKey) # the vert lines
    axisLabels = axisLabels.concat(outerTicksToDraw).concat(innerTicksToDraw)
    {axisTicks, axisLabels}


  # Given a time range, produces a sequence of tick marks at incrementing dates.
  # It only does it for one grain at a time (i.e. "year"). So if you want to show multiple
  # grains, run this function for each grain.
  allTicksOnAxisForGrain: (grain, timeScale) ->
    {domain} = timeScale
    [ startEpoch, endEpoch ] = domain
    [ startDate, endDate ] = [ new Date(domain[0]), new Date(domain[1]) ]

    ticks = [] # the array to populate with all of the time axis tick marks
    dateString = null # ie "2001/01/20" which is used in the shape key
    numGrainsInDateString = 3 # i.e '2001/01' is 2, '2001/01/30' is 3
    increment = # a function that increments a single date grain
      switch grain
        when "day"
          (tickDate) =>
            tickDate.setDate tickDate.getDate() + 1
            dateString = @formatDateString tickDate, numGrainsInDateString
        when "month"
          # start with the first full month, unless we have less than a month of data
          numGrainsInDateString = 2
          isOneMonth = startDate.getMonth() is endDate.getMonth() and startDate.getFullYear() is endDate.getFullYear()
          if startDate.getDate() > 15 and not isOneMonth
            startDate.setMonth startDate.getMonth() + 1
            startDate.setDate 1
          (tickDate) =>
            tickDate.setMonth tickDate.getMonth() + 1
            tickDate.setDate 1
            dateString = @formatDateString tickDate, numGrainsInDateString
        when "year"
          numGrainsInDateString = 1
          # start with the first full year, unless we have one year of data
          isOneYear = startDate.getFullYear() is endDate.getFullYear()
          if not isOneYear and endDate.getMonth() isnt 0 # jan
            startDate.setFullYear startDate.getFullYear() + 1
            startDate.setMonth 0
            startDate.setDate 1
            dateString = @formatDateString startDate, numGrainsInDateString
          (tickDate) =>
            tickDate.setFullYear tickDate.getFullYear() + 1
            tickDate.setMonth 0 # safegaurd, always want first month of year
            tickDate.setDate 1
            dateString = @formatDateString tickDate, numGrainsInDateString
        else
          break

    # Pushes each consecutive grain into an array (Jan, Feb, March...)
    while startDate.getTime() <= endEpoch
      if not dateString
        dateString = @formatDateString startDate, numGrainsInDateString
      newTickDate = new Date(startDate.getTime()) # create a new one to store because we increment the original
      ticks.push # this array is created in the main function
        date: newTickDate
        grain: grain
        dateString: dateString
      increment startDate
    ticks

  isOutermostGroup: (tickGroup) ->
    tickGroup.row is tickGroup.numRows

  #--------------------------------------------------------------------------------
  # Styling
  #--------------------------------------------------------------------------------

  getOpacity: (shape) ->
    isLabel = @typeOfShapeFromKey(shape.key) is 'tick'
    if isLabel then 1 else .2

  getFontSize: (row, numRows) ->
    if row is numRows
      @FONT_LARGEST_TIME_AXIS
    else if row is 1
      @FONT_LARGEST_TIME_AXIS - 3
    else if row is 2
      @FONT_LARGEST_TIME_AXIS - 2
    else
      @FONT_LARGEST_TIME_AXIS

  # The Y length of a hash mark
  getY: (shape) ->
    {row} = shape
    if row is 1
      @SMALLEST_HASH_MARK
    else
      @SMALLEST_HASH_MARK * row + 2

  getX: (shape, timeScale = @props.scale) ->
    isLabel = @typeOfShapeFromKey(shape.key) is 'tick'
    if isLabel
      {row, numRows, date, grain, textWidth} = shape
      epoch = date.getTime()
      if row is numRows
        timeScale.map(epoch) + 5 # some padding
      else # middle align the text
        middleEpoch = DateUtils.midPointOfGrain(date, grain).getTime()
        centerInPixels = timeScale.map middleEpoch
        centerInPixels - textWidth/2
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

  # Formats positions for labels
  formatTickLayout: (tick) ->
    $.extend tick,
      y: @getY tick
      x: @getX tick
      opacity: @getOpacity tick
    tick


  # Formats positions for the vert lines on the time axis
  formatHashMarkLayout: (tickHash) ->
    x = @getX tickHash
    $.extend tickHash,
      x0: x
      x1: x
      y0: 0
      y1: @getY tickHash
      opacity: @getOpacity tickHash
    tickHash

  # ----------------------------------------------
  # Text measuring, abbreviation, etc.
  # ----------------------------------------------

  getTextMetrics: (text, fontSize) ->
      measureText(
        text,
        200, # default width.  Still not sure why this has to be passed
        @FONT_FACE,
        fontSize,
        fontSize + 5 # lineHeight
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
    {year, quarter, month, week, day} = dateObj = DateUtils.timeToDateObj date.getTime()

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

    getQuarter = ->
      switch truncateIndex
        when 0
          "Q" + dateObj[grain]
        when 1
          dateObj[grain]
        else
          if row is numRows then dateObj[grain] else ""
    getDay = ->
      switch truncateIndex
        when 0
          dateObj[grain]
        else
          ""
    switch grain
      when "month"
        getMonth()
      when "quarter"
        getQuarter()
      when "day"
        getDay()
      else # the default formatting
        switch truncateIndex
          when 0
            dateObj[grain]
          else
            # this is the smallest text we can show for that tick (month and quarter override this)
            if row is numRows then dateObj[grain] else ""

  formatKeyForTick: (tick) ->
    "tick#{@KEY_DIVIDER}#{tick.grain}#{@KEY_DIVIDER}#{tick.dateString}"

  formatKeyForHashMark: (hash) ->
    "hash#{@KEY_DIVIDER}#{hash.grain}#{@KEY_DIVIDER}#{hash.dateString}"

  formatDateString: (date, numGrainsInDateString) ->
    dateArray = [date.getFullYear(), date.getMonth(), date.getDate()][0...numGrainsInDateString]
    dateArray.join @DATE_STR_DIVIDER

module.exports = TimeAxis

