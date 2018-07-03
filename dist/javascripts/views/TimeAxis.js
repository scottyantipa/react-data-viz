var $, Axis, DateUtils, FontFace, Group, Line, React, Text, TimeAxis, _, createReactClass, measureText, moment, ref;

ref = require('react-canvas'), measureText = ref.measureText, Line = ref.Line, Group = ref.Group, Text = ref.Text, FontFace = ref.FontFace;

React = require('react');

createReactClass = require('create-react-class');

_ = require('underscore');

$ = require('jquery');

moment = require('moment');

Axis = require('./Axis');

DateUtils = require('../util/DateUtils');


/*
Renders a time axis with multiple levels of granularity.  For example,
If days are the smallest grain we can show, it will also render months and years.
"Ticks" denote a position on the axis.  A "Hash" is a vertical line marking the axis.
 */

TimeAxis = createReactClass({
  displayName: 'TimeAxis',
  POSSIBLE_GRAINS: ["second", "minute", "hour", "day", "month", "year"],
  PIXELS_BETWEEN_HASHES: 8,
  LABEL_PADDING: 3,
  SMALLEST_HASH_MARK: 15,
  FONT_LARGEST_TIME_AXIS: 13,
  FONT_FACE: FontFace.Default(600),
  KEY_DIVIDER: "::",
  render: function() {
    var axisHashes, axisLabels, ref1;
    ref1 = this.calcShapes(), axisLabels = ref1.axisLabels, axisHashes = ref1.axisHashes;
    return React.createElement(Group, null, this.renderLabels(axisLabels), this.renderHashes(axisHashes), this.renderAxisLine());
  },
  renderLabels: function(labels) {
    var origin;
    origin = this.props.origin;
    return _.map(labels, (function(_this) {
      return function(label, index) {
        var baseTextStyle, fontSize, style, text, width, x, y;
        x = label.x, y = label.y, text = label.text, fontSize = label.fontSize, width = label.width;
        baseTextStyle = _.clone(_this.props.textStyle);
        style = _.extend(baseTextStyle, {
          left: x + origin.x,
          top: y + origin.y,
          fontSize: fontSize,
          width: width
        });
        return React.createElement(Text, {
          "style": style,
          "key": index
        }, text);
      };
    })(this));
  },
  renderHashes: function(hash) {
    var origin;
    origin = this.props.origin;
    return _.map(hash, (function(_this) {
      return function(hash, index) {
        var frame, style, x, y0, y1;
        x = hash.x, y0 = hash.y0, y1 = hash.y1;
        x += origin.x;
        frame = {
          x0: x,
          y0: origin.y + y0,
          x1: x,
          y1: origin.y + y1
        };
        style = _.extend(_this.props.axisLineStyle, {
          opacity: .5,
          lineWidth: .5
        });
        return React.createElement(Line, {
          "style": style,
          "frame": frame,
          "key": index
        });
      };
    })(this));
  },
  renderAxisLine: function() {
    var axisFrame, ref1, x, y;
    ref1 = this.props.origin, x = ref1.x, y = ref1.y;
    axisFrame = {
      x0: x,
      y0: y,
      x1: x + this.props.scale.range[1],
      y1: y
    };
    return React.createElement(Line, {
      "frame": axisFrame,
      "style": this.props.axisLineStyle
    });
  },
  calcShapes: function() {
    var axisHashes, axisLabels, date, epoch, fontRatio, fontSize, grain, group, groupIndex, groupsRemoved, hash, hashByKey, i, index, innerTicksToDraw, j, k, l, largest, largestTruncation, len, len1, len10, len11, len2, len3, len4, len5, len6, len7, len8, len9, maxWidth, n, numRows, numToSkip, numberSkippedInARow, o, outerMostTickGroup, outerTicksToDraw, p, q, r, ref1, ref2, ref3, ref4, row, s, spacePerTick, t, text, textFitsInMaxSpace, textIsntCollapsed, textWidth, tick, tickGroup, tickGroups, tickIndex, ticks, truncateIndex, u, v, width, widthOfLargest;
    numRows = this.POSSIBLE_GRAINS.length;
    axisLabels = [];
    axisHashes = [];
    tickGroups = [];
    ref1 = this.POSSIBLE_GRAINS;
    for (row = j = 0, len = ref1.length; j < len; row = ++j) {
      grain = ref1[row];
      ticks = this.ticksForGrain(grain, this.props.scale);
      if (!ticks) {
        continue;
      }
      group = {
        ticks: ticks,
        grain: grain
      };
      tickGroups.push(group);
    }

    /*
    Create the hash marks (the little vertical lines on the time axis).
    We will draw a hash mark for every tick, however, there will be overlap so we
    only draw one in this case.  For example, on January, 1, 2001, there are three (for year, month, and day)
     */
    for (i = k = 0, len1 = tickGroups.length; k < len1; i = ++k) {
      tickGroup = tickGroups[i];
      if (i === tickGroups.length - 1) {
        continue;
      }
      if (tickGroup.ticks.length > (this.props.scale.dy / this.PIXELS_BETWEEN_HASHES)) {
        tickGroup.dontDrawHashes = true;
      }
    }
    this.y = this.hashLengthForRow(_.last(tickGroups).row);
    for (l = 0, len2 = tickGroups.length; l < len2; l++) {
      tickGroup = tickGroups[l];
      ticks = tickGroup.ticks, grain = tickGroup.grain, row = tickGroup.row;
      for (n = 0, len3 = ticks.length; n < len3; n++) {
        tick = ticks[n];
        tick.grain = grain;
        tick.key = this.formatKeyForTick(tick);
      }
    }

    /*
    Figure out the truncateIndex for each group.  This is the level to which
    their label needs to be abbreviated (like "January" --> "Jan" --> "J" --> "").  All ticks in a
    group  will be truncated to the same level of abbreviation, for example... if September needs to be written as
    just "Sep", but "March" can fit fine as it is, we still chop down "March" to "Mar" for consistency.)
     */
    for (groupIndex = o = 0, len4 = tickGroups.length; o < len4; groupIndex = ++o) {
      tickGroup = tickGroups[groupIndex];
      ticks = tickGroup.ticks;
      spacePerTick = this.props.scale.dy / ticks.length;
      maxWidth = spacePerTick - 2 * this.LABEL_PADDING;
      if (maxWidth < 10) {
        tickGroup.labelsCannotFit = true;
      }
      largestTruncation = 0;
      widthOfLargest = 0;
      fontSize = this.FONT_LARGEST_TIME_AXIS;
      for (tickIndex = p = 0, len5 = ticks.length; p < len5; tickIndex = ++p) {
        tick = ticks[tickIndex];
        truncateIndex = -1;
        textIsntCollapsed = true;
        textFitsInMaxSpace = false;
        while (textIsntCollapsed && !textFitsInMaxSpace) {
          truncateIndex++;
          if (!(text = this.formatTimeAxisLabel(tick, truncateIndex))) {
            textIsntCollapsed = false;
            truncateIndex--;
          } else {
            width = this.getTextMetrics(text, fontSize).lines[0].width;
            textFitsInMaxSpace = width <= maxWidth;
          }
        }
        widthOfLargest = Math.max(width, widthOfLargest);
        largestTruncation = Math.max(truncateIndex, largestTruncation);
      }
      tickGroup.widthOfLargest = widthOfLargest;
      tickGroup.truncateIndex = largestTruncation;
    }
    groupsRemoved = 0;
    while (tickGroups[0].labelsCannotFit && tickGroups[0].dontDrawHashes && groupsRemoved < this.POSSIBLE_GRAINS.length) {
      groupsRemoved++;
      tickGroups.splice(0, 1);
    }
    tickGroups = tickGroups.slice(0, 3);
    for (i = q = 0, len6 = tickGroups.length; q < len6; i = ++q) {
      tickGroup = tickGroups[i];
      row = i + 1;
      numRows = tickGroups.length;
      tickGroup.row = row;
      tickGroup.numRows = numRows;
      ref2 = tickGroup.ticks;
      for (r = 0, len7 = ref2.length; r < len7; r++) {
        tick = ref2[r];
        tick.row = row;
        tick.numRows = numRows;
      }
    }
    innerTicksToDraw = [];
    for (groupIndex = s = 0, len8 = tickGroups.length; s < len8; groupIndex = ++s) {
      tickGroup = tickGroups[groupIndex];
      ticks = tickGroup.ticks, row = tickGroup.row, numRows = tickGroup.numRows, truncateIndex = tickGroup.truncateIndex, grain = tickGroup.grain;
      if (tickGroup.labelsCannotFit || groupIndex === tickGroups.length - 1) {
        continue;
      }
      fontSize = this.getFontSize(row, numRows);
      for (tickIndex = t = 0, len9 = ticks.length; t < len9; tickIndex = ++t) {
        tick = ticks[tickIndex];
        date = tick.date;
        text = this.formatTimeAxisLabel(tick, truncateIndex);
        if (!text) {
          continue;
        }
        textWidth = this.getTextMetrics(text, fontSize).lines[0].width;
        $.extend(tick, {
          text: text,
          fontSize: fontSize,
          width: textWidth
        });
        tick = this.formatTickLayout(tick);
        if (tick.x + textWidth > this.props.scale.dy) {
          continue;
        }
        innerTicksToDraw.push(tick);
      }
    }
    hashByKey = {};
    i = tickGroups.length;
    while (i > 0) {
      tickGroup = tickGroups[i - 1];
      if (tickGroup.dontDrawHashes || i === tickGroups.length) {
        i--;
        continue;
      }
      ref3 = tickGroup.ticks;
      for (tickIndex = u = 0, len10 = ref3.length; u < len10; tickIndex = ++u) {
        tick = ref3[tickIndex];
        this.addHashMarkFromTick(tick, hashByKey, this.props.scale, false);
      }
      i--;
    }
    outerMostTickGroup = _.last(tickGroups);
    numToSkip = 1;
    largest = outerMostTickGroup.widthOfLargest;
    while ((largest + 2 * this.LABEL_PADDING) * (outerMostTickGroup.ticks.length / numToSkip) > this.props.scale.dy * .7) {
      numToSkip++;
    }
    numberSkippedInARow = 0;
    outerTicksToDraw = [];
    row = outerMostTickGroup.row, grain = outerMostTickGroup.grain;
    fontSize = this.getFontSize(row, tickGroups.length);
    fontRatio = fontSize / 12;
    ref4 = outerMostTickGroup.ticks;
    for (index = v = 0, len11 = ref4.length; v < len11; index = ++v) {
      tick = ref4[index];
      if (numberSkippedInARow < numToSkip && numToSkip !== 1 && index !== 0) {
        numberSkippedInARow++;
      } else {
        numberSkippedInARow = 0;
        this.addHashMarkFromTick(tick, hashByKey, this.props.scale, true);
        text = this.formatTimeAxisLabel(tick, 0);
        textWidth = fontRatio * this.getTextMetrics(text, fontSize).lines[0].width;
        tick = this.formatTickLayout(tick);
        $.extend(tick, {
          text: text,
          fontSize: fontSize
        });
        if (tick.x + textWidth > this.props.scale.dy) {
          continue;
        }
        tick.width = textWidth;
        outerTicksToDraw.push(tick);
      }
    }
    axisHashes = (function() {
      var results;
      results = [];
      for (epoch in hashByKey) {
        hash = hashByKey[epoch];
        results.push(this.formatHashMarkLayout(hash));
      }
      return results;
    }).call(this);
    axisLabels = axisLabels.concat(outerTicksToDraw).concat(innerTicksToDraw);
    return {
      axisHashes: axisHashes,
      axisLabels: axisLabels
    };
  },
  ticksForGrain: function(grain, timeScale) {
    var domain, endEpoch, incrementer, numTicks, pointer, startEpoch, ticks, time;
    domain = timeScale.domain;
    startEpoch = domain[0], endEpoch = domain[1];
    ticks = [
      {
        date: new Date(startEpoch),
        grain: grain
      }
    ];
    pointer = DateUtils.roundDateToGrain(new Date(startEpoch), grain);
    incrementer = DateUtils.incrementerForGrain[grain];
    numTicks = 0;
    while ((time = pointer.getTime()) <= endEpoch) {
      if (time < startEpoch) {
        incrementer(pointer);
        continue;
      }
      ticks.push({
        date: new Date(time),
        grain: grain
      });
      incrementer(pointer);
      numTicks++;
      if (numTicks >= 500) {
        return false;
      }
    }
    return ticks;
  },
  getFontSize: function(row, numRows) {
    if (row === numRows) {
      return this.FONT_LARGEST_TIME_AXIS;
    } else if (row === 1) {
      return this.FONT_LARGEST_TIME_AXIS - 4;
    } else if (row === 2) {
      return this.FONT_LARGEST_TIME_AXIS - 3;
    } else {
      return this.FONT_LARGEST_TIME_AXIS;
    }
  },
  hashLengthForRow: function(row) {
    return this.SMALLEST_HASH_MARK * row;
  },
  getX: function(shape, timeScale, centerText) {
    var centerInPixels, date, epoch, grain, isLabel, middleEpoch, numRows, row, width;
    if (timeScale == null) {
      timeScale = this.props.scale;
    }
    isLabel = this.typeOfShapeFromKey(shape.key) === 'tick';
    if (isLabel) {
      row = shape.row, numRows = shape.numRows, date = shape.date, grain = shape.grain, width = shape.width;
      epoch = date.getTime();
      if (centerText) {
        middleEpoch = DateUtils.midPointOfGrain(date, grain).getTime();
        centerInPixels = timeScale.map(middleEpoch);
        return centerInPixels - width / 2;
      } else {
        return timeScale.map(epoch) + this.LABEL_PADDING;
      }
    } else {
      epoch = shape.date.getTime();
      return timeScale.map(epoch);
    }
  },
  typeOfShapeFromKey: function(key) {
    var parts;
    parts = key.split(this.KEY_DIVIDER);
    return parts[0];
  },
  addHashMarkFromTick: function(tick, hashMap, timeScale, shouldOverride) {
    var epoch, hashKey, tickHash;
    if (shouldOverride == null) {
      shouldOverride = false;
    }
    tickHash = $.extend({}, tick);
    epoch = tick.date.getTime();
    hashKey = this.formatKeyForHashMark(tickHash);
    if (!shouldOverride && hashMap[epoch]) {
      return;
    }
    hashMap[epoch] = tickHash;
    tickHash.key = hashKey;
    return tickHash.x = timeScale.map(tickHash.date.getTime());
  },
  formatTickLayout: function(tick) {
    return $.extend(tick, {
      y: this.hashLengthForRow(tick.row) - 13,
      x: this.getX(tick)
    });
  },
  formatHashMarkLayout: function(tickHash) {
    var x;
    x = this.getX(tickHash);
    return $.extend(tickHash, {
      x: x,
      y0: 0,
      y1: this.hashLengthForRow(tickHash.row)
    });
  },
  getTextMetrics: function(text, fontSize) {
    return measureText(text, 200, this.FONT_FACE, fontSize, fontSize);
  },

  /*
  This formats the labels on the time line axis
  arguments:
    tick:
      Info for the mark on the time axis (the date, the scale -- like "year")
    truncateIndex:
      How much we need to abbreviate the text by (its an integer)
   */
  formatTimeAxisLabel: function(tick, truncateIndex) {
    var date, dateObj, formatter, grain, isFirstTick, numRows, row, val;
    if (truncateIndex == null) {
      truncateIndex = 0;
    }
    date = tick.date, grain = tick.grain, row = tick.row, numRows = tick.numRows, isFirstTick = tick.isFirstTick;
    dateObj = DateUtils.timeToDateObj(date.getTime());
    val = (function() {
      if (formatter = this.formatLabelByGrain[grain]) {
        return formatter(truncateIndex, dateObj);
      } else {
        switch (truncateIndex) {
          case 0:
            return dateObj[grain];
        }
      }
    }).call(this);
    if (val) {
      return val.toString();
    } else {
      return void 0;
    }
  },
  formatLabelByGrain: {
    second: function(truncateIndex, arg) {
      var second;
      second = arg.second;
      switch (truncateIndex) {
        case 0:
          return second + 's';
        case 1:
          return second;
      }
    },
    minute: function(truncateIndex, arg) {
      var minute;
      minute = arg.minute;
      switch (truncateIndex) {
        case 0:
          return minute + 'm';
        case 1:
          return minute;
      }
    },
    hour: function(truncateIndex, arg) {
      var date;
      date = arg.date;
      switch (truncateIndex) {
        case 0:
          return moment(date).format('ha');
        case 1:
          return moment(date).format('h');
      }
    },
    day: function(truncateIndex, arg) {
      var date;
      date = arg.date;
      switch (truncateIndex) {
        case 0:
          return moment(date).format("Do");
        case 1:
          return date.getDate();
      }
    },
    month: function(truncateIndex, arg) {
      var date, m;
      date = arg.date;
      m = moment(date);
      switch (truncateIndex) {
        case 0:
          return m.format('MMMM');
        case 1:
          return m.format('MMM');
        case 2:
          return m.format('MMM')[0];
      }
    }
  },
  formatKeyForTick: function(tick) {
    return ["tick", tick.grain, "" + (tick.date.getTime())].join(this.KEY_DIVIDER);
  },
  formatKeyForHashMark: function(hash) {
    return ["hash", hash.grain, "" + (hash.date.getTime())].join(this.KEY_DIVIDER);
  }
});

module.exports = TimeAxis;
