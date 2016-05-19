moment = require 'moment'
_ = require 'underscore'

DateUtils =

  # Return the epoch for the middle of a date range
  # Takes a JS date obj and returns the mid point between
  # It and the next month, year, etc.
  # i.e. Jan, 2011 will return JS Date for Jan, 15, 2011
  midPointOfGrain: (date, grain) ->
    nextDate = @dateOfNextScale date, grain
    halfDiff = (nextDate.getTime() - date.getTime()) / 2
    new Date(date.getTime() + halfDiff)

  timeToDateObj: (time) ->
    date = new Date time
    if isNaN(date.getTime()) then return false

    year       : date.getFullYear()
    month      : date.getMonth()
    day        : date.getDate()
    hour       : date.getHours()
    minute     : date.getMinutes()
    second     : date.getSeconds()
    millisecond: date.getMilliseconds()
    date       : date

  grainsInOrder: ['year', 'month', 'day', 'hour', 'minute', 'second', 'millisecond']

  # Given a date and grain (e.g. 'minute') round all finer grain components
  # of the date to zero (e.g. if 'minute', set seconds and ms to 0)
  roundDateToGrain: (date, grain) ->
    {year, month, day, hour, minute, second, millisecond} = @timeToDateObj date.getTime()
    allGrains = [year, month, day, hour, minute, second, millisecond]
    grainIndex = _.indexOf @grainsInOrder, grain
    truncated = allGrains.slice 0, grainIndex + 1
    moment(truncated).toDate()

  # Return a function that increments a date by a single unit
  # of the given grain (e.g. 'month' means add 1 month)
  incrementerForGrain:
    second: (date) -> date.setSeconds date.getSeconds() + 1
    minute: (date) -> date.setMinutes date.getMinutes() + 1
    hour  : (date) -> date.setHours date.getHours() + 1
    day   : (date) -> date.setDate date.getDate() + 1
    month : (date) -> date.setMonth date.getMonth() + 1
    year  : (date) -> date.setFullYear date.getFullYear() + 1


  # Example: January will return the first day of Feb
  # Example: 2008 will return first day of 2009
  dateOfNextScale: (date, grain) ->
    d = new Date date.getTime()
    switch grain
      when 'second'
        d.setSeconds d.getSeconds() + 1
        d.setMilliseconds d.getMilliseconds() + 1
      when 'minute'
        d.setMinutes d.getMinutes() + 1
        d.setSeconds 0
      when 'hour'
        d.setHours d.getHours() + 1
        d.setMinutes 0
      when 'day'
        d.setDate d.getDate() + 1
        d.setHours 0
      when 'month'
        d.setMonth d.getMonth() + 1
        d.setDate 1
      when 'year'
        d.setYear d.getFullYear() + 1
        d.setMonth 0
      else
        null
    d


module.exports = DateUtils
