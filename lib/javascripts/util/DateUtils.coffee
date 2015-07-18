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
    month: date.getMonth()
    week: 4 * (date.getMonth()) + (Math.floor(date.getDate() / 7) + 1)
    day: date.getDate()
    hour: date.getHours()


  # i.e. January will return the first day of Feb, or 2008 will return first
  # day of 2009
  dateOfNextScale: (date, grain) ->
    d = new Date date.getTime()
    switch grain
      when "hour"
        d.setHours d.getHours() + 1
        d.setMinutes 0
      when "day"
        d.setDate d.getDate() + 1
        d.setHours 0
      when "week"
        d.setDate d.getDate() + 7
      when "month"
        d.setMonth d.getMonth() + 1
        d.setDate 1
      when "year"
        d.setYear d.getFullYear() + 1
        d.setMonth 0
      else
        null
    d


  getFebDays: (year) ->
    return false if not @isValidYear(year)
    mnth = 1
    i = 0
    while (mnth is 1)
      i++
      dateObj = new Date(year, 1, i)
      mnth = dateObj.getMonth()
    i - 1

  isValidMonth: (month) ->
    _.isNumber(month) and [0..11].indexOf(month) isnt -1

  isValidYear: (year) ->
    _.isNumber(year) and year.toString().length is 4


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