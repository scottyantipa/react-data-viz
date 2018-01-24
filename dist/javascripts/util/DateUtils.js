var DateUtils, _, moment;

_ = require('underscore');

moment = require('moment');

DateUtils = {
  midPointOfGrain: function(date, grain) {
    var halfDiff, nextDate;
    nextDate = this.dateOfNextScale(date, grain);
    halfDiff = (nextDate.getTime() - date.getTime()) / 2;
    return new Date(date.getTime() + halfDiff);
  },
  timeToDateObj: function(time) {
    var date;
    date = new Date(time);
    if (isNaN(date.getTime())) {
      return false;
    }
    return {
      year: date.getFullYear(),
      month: date.getMonth(),
      day: date.getDate(),
      hour: date.getHours(),
      minute: date.getMinutes(),
      second: date.getSeconds(),
      millisecond: date.getMilliseconds(),
      date: date
    };
  },
  grainsInOrder: ['year', 'month', 'day', 'hour', 'minute', 'second', 'millisecond'],
  roundDateToGrain: function(date, grain) {
    var allGrains, day, grainIndex, hour, millisecond, minute, month, ref, second, truncated, year;
    ref = this.timeToDateObj(date.getTime()), year = ref.year, month = ref.month, day = ref.day, hour = ref.hour, minute = ref.minute, second = ref.second, millisecond = ref.millisecond;
    allGrains = [year, month, day, hour, minute, second, millisecond];
    grainIndex = _.indexOf(this.grainsInOrder, grain);
    truncated = allGrains.slice(0, grainIndex + 1);
    return moment(truncated).toDate();
  },
  incrementerForGrain: {
    second: function(date) {
      return date.setSeconds(date.getSeconds() + 1);
    },
    minute: function(date) {
      return date.setMinutes(date.getMinutes() + 1);
    },
    hour: function(date) {
      return date.setHours(date.getHours() + 1);
    },
    day: function(date) {
      return date.setDate(date.getDate() + 1);
    },
    month: function(date) {
      return date.setMonth(date.getMonth() + 1);
    },
    year: function(date) {
      return date.setFullYear(date.getFullYear() + 1);
    }
  },
  dateOfNextScale: function(date, grain) {
    var d;
    d = new Date(date.getTime());
    switch (grain) {
      case 'second':
        d.setSeconds(d.getSeconds() + 1);
        d.setMilliseconds(d.getMilliseconds() + 1);
        break;
      case 'minute':
        d.setMinutes(d.getMinutes() + 1);
        d.setSeconds(0);
        break;
      case 'hour':
        d.setHours(d.getHours() + 1);
        d.setMinutes(0);
        break;
      case 'day':
        d.setDate(d.getDate() + 1);
        d.setHours(0);
        break;
      case 'month':
        d.setMonth(d.getMonth() + 1);
        d.setDate(1);
        break;
      case 'year':
        d.setYear(d.getFullYear() + 1);
        d.setMonth(0);
        break;
      default:
        null;
    }
    return d;
  }
};

module.exports = DateUtils;
