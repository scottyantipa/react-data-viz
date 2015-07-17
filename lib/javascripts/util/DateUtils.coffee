DateUtils =

  # Return the epoch for the middle of a date range
  # Takes a JS date obj and returns the mid point between
  # It and the next month, year, etc.
  # i.e. Jan, 2011 will return JS Date for Jan, 15, 2011
  midPointOfGrain: (date, grain) ->
    nextDate = @dateOfNextScale date, grain
    if not nextDate then return @DATE_GRAIN_INFO[grain].numMilSeconds / 2
    halfDiff = (nextDate.getTime() - date.getTime()) / 2
    new Date(date.getTime() + halfDiff)


  timeToDateObj: (time) ->
    date = new Date time
    if isNaN(date.getTime()) then return false

    year: date.getFullYear()
    quarter: @getQuarter(date.getMonth() + 1)
    month: date.getMonth()
    week: 4 * (date.getMonth()) + (Math.floor(date.getDate() / 7) + 1)
    day: date.getDate()


  # i.e. January will return the first day of Feb, or 2008 will return first
  # day of 2009
  dateOfNextScale: (date, grain) ->
    switch grain
      when "day"
        new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)
      when "month"
        new Date(date.getFullYear(), date.getMonth() + 1, 1)
      when "quarter"
        new Date(date.getFullYear(), date.getMonth() + 3, date.getDate())
      when "year"
        new Date(date.getFullYear() + 1, 0, 1)
      when "week"
        new Date(date.getFullYear(), date.getMonth(), date.getDate() + 7)
      else
        null

  dateOfPreviousScale: (date, grain) ->
    switch grain
      when "day"
        new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1)
      when "month"
        new Date(date.getFullYear(), date.getMonth() - 1, date.getDate())
      when "quarter"
        new Date(date.getFullYear(), date.getMonth() - 3, date.getDate())
      when "year"
        new Date(date.getFullYear() - 1, 0, 1)
      when "week"
        new Date(date.getFullYear(), date.getMonth(), date.getDate() + 7)
      else
        null


  # For a given grain return the first day (i.e 2008/4/2 for grain "year"
  # will return a new date for 2008/1/1)
  firstDateInGrain: (date, grain) ->
    switch grain
      when "year"
        new Date(date.getFullYear(), 0, 1)
      when "quarter"
        firstMonths = @FIRST_MONTH_OF_QUARTERS # [0, 3, 6, 9]
        currentMonth = date.getMonth()
        while currentMonth not in firstMonths and currentMonth > 0
          currentMonth--
        new Date(date.getFullYear(), currentMonth, 1)
      when "month"
        new Date(date.getFullYear(), date.getMonth(), 1)
      when "day"
        new Date date.getFullYear(), date.getMonth(), date.getDate()
      else
        null

  # For a given grain return the last day (i.e 2008/4/2 for grain "year"
  # will return a new date for 2008/12/31)
  lastDateInGrain: (date, grain) ->
    switch grain
      when "year"
        new Date(date.getFullYear(), 11, 31)
      when "quarter"
        lastMonths = @LAST_MONTH_OF_QUARTERS # [2, 5, 8, 11]
        currentMonth = date.getMonth()
        while currentMonth not in lastMonths and currentMonth < 11
          currentMonth++
        daysInMonth = @NUM_DAYS_EACH_MONTH[currentMonth] or @getFebDays(currentMonth)
        new Date(date.getFullYear(), currentMonth, daysInMonth)
      when "month"
        nextMonth = @dateOfNextScale date, grain
        new Date(nextMonth.getFullYear(), nextMonth.getMonth(), nextMonth.getDate())
      when "day"
        copy = new Date date.getFullYear(), date.getMonth(), date.getDate()
        copy.setDate copy.getDate() + 1
        copy
      else
        null

  nearestWholeDate: (date, grain) ->
    previous = @firstDateInGrain date, grain
    next = @lastDateInGrain date, grain
    diffToPrevious = date.getTime() - previous.getTime()
    diffToNext = next.getTime() - date.getTime()
    if diffToPrevious > diffToNext
      next
    else
      previous

  getQuarter: (month) ->
    return false if not @isValidMonth(month)
    Math.floor(month/3) + 1

  firstMonthOfQrt: (quarter) ->
    return false if not @isValidQuarter(quarter)
    quarter * 3 - 3

  lastMonthOfQrt: (quarter) ->
    return false if not @isValidQuarter(quarter)
    quarter * 3 - 1

  getFebDays: (year) ->
    return false if not @isValidYear(year)
    mnth = 1
    i = 0
    while (mnth is 1)
      i++
      dateObj = new Date(year, 1, i)
      mnth = dateObj.getMonth()
    i - 1


  isValidQuarter: (quarter) ->
    [1,2,3,4, "1", "2", "3", "4"].indexOf(quarter) isnt -1

  isValidMonth: (month) ->
    _.isNumber(month) and [0..11].indexOf(month) isnt -1

  isValidYear: (year) ->
    _.isNumber(year) and year.toString().length is 4

  FIRST_MONTH_OF_QUARTERS: [0, 3, 6, 9]


  DATE_GRAIN_INFO:
    second:
      name: "second"
      index: 1
      numMilSeconds: 1000
    minute:
      name: "minute"
      index: 2
      numMilSeconds: 60000
    hour:
      name: "hour"
      index: 3
      numMilSeconds: 3600000
    day:
      name: "day"
      index: 4
      numMilSeconds: 86400000
    month:
      name: "month"
      index: 5
      numMilSeconds: null
    quarter:
      name: "quarter"
      index: 6
      numMilSeconds: null
    year:
      name: "year"
      index: 7
      numMilSeconds: null

  MONTH_INFOS: [
    {calInt: 0, name: 'Jan', days: 31, longName: 'January'}
    {calInt: 1, name: 'Feb', days: null, longName: 'February'}
    {calInt: 2, name: 'Mar', days: 31, longName: 'March'}
    {calInt: 3, name: 'Apr', days: 30, longName: 'April'}
    {calInt: 4, name: 'May', days: 31, longName: 'May'}
    {calInt: 5, name: 'Jun', days: 30, longName: 'June'}
    {calInt: 6, name: 'Jul', days: 31, longName: 'July'}
    {calInt: 7, name: 'Aug', days: 31, longName: 'August'}
    {calInt: 8, name: 'Sep', days: 30, longName: 'September'}
    {calInt: 9, name: 'Oct', days: 31, longName: 'October'}
    {calInt: 10, name: 'Nov', days: 30, longName: 'November'}
    {calInt: 11, name: 'Dec', days: 31, longName: 'December'}
  ]

module.exports = DateUtils