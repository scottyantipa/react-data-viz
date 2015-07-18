(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ReactDataViz;

ReactDataViz = {
  LinearScale: require('./javascripts/util/LinearScale.coffee'),
  OrdinalScale: require('./javascripts/util/OrdinalScale.coffee'),
  Axis: require('./javascripts/views/Axis.cjsx'),
  TimeAxis: require('./javascripts/views/TimeAxis.cjsx')
};

window.ReactDataViz = ReactDataViz;
},{"./javascripts/util/LinearScale.coffee":3,"./javascripts/util/OrdinalScale.coffee":4,"./javascripts/views/Axis.cjsx":5,"./javascripts/views/TimeAxis.cjsx":6}],2:[function(require,module,exports){
var DateUtils;

DateUtils = {
  midPointOfGrain: function(date, grain) {
    var halfDiff, nextDate;
    nextDate = this.dateOfNextScale(date, grain);
    if (!nextDate) {
      return this.DATE_GRAIN_INFO[grain].numMilSeconds / 2;
    }
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
      week: 4 * (date.getMonth()) + (Math.floor(date.getDate() / 7) + 1),
      day: date.getDate(),
      hour: date.getHours()
    };
  },
  dateOfNextScale: function(date, grain) {
    var d;
    d = new Date(date.getTime());
    switch (grain) {
      case "hour":
        d.setHours(d.getHours() + 1);
        d.setMinutes(0);
        break;
      case "day":
        d.setDate(d.getDate() + 1);
        d.setHours(0);
        break;
      case "week":
        d.setDate(d.getDate() + 7);
        break;
      case "month":
        d.setMonth(d.getMonth() + 1);
        d.setDate(1);
        break;
      case "year":
        d.setYear(d.getFullYear() + 1);
        d.setMonth(0);
        break;
      default:
        null;
    }
    return d;
  },
  getFebDays: function(year) {
    var dateObj, i, mnth;
    if (!this.isValidYear(year)) {
      return false;
    }
    mnth = 1;
    i = 0;
    while (mnth === 1) {
      i++;
      dateObj = new Date(year, 1, i);
      mnth = dateObj.getMonth();
    }
    return i - 1;
  },
  isValidMonth: function(month) {
    return _.isNumber(month) && [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].indexOf(month) !== -1;
  },
  isValidYear: function(year) {
    return _.isNumber(year) && year.toString().length === 4;
  },
  DATE_GRAIN_INFO: {
    second: {
      name: "second",
      index: 1,
      numMilSeconds: 1000
    },
    minute: {
      name: "minute",
      index: 2,
      numMilSeconds: 60000
    },
    hour: {
      name: "hour",
      index: 3,
      numMilSeconds: 3600000
    },
    day: {
      name: "day",
      index: 4,
      numMilSeconds: 86400000
    },
    month: {
      name: "month",
      index: 5,
      numMilSeconds: null
    },
    year: {
      name: "year",
      index: 7,
      numMilSeconds: null
    }
  },
  MONTH_INFOS: [
    {
      calInt: 0,
      name: 'Jan',
      days: 31,
      longName: 'January'
    }, {
      calInt: 1,
      name: 'Feb',
      days: null,
      longName: 'February'
    }, {
      calInt: 2,
      name: 'Mar',
      days: 31,
      longName: 'March'
    }, {
      calInt: 3,
      name: 'Apr',
      days: 30,
      longName: 'April'
    }, {
      calInt: 4,
      name: 'May',
      days: 31,
      longName: 'May'
    }, {
      calInt: 5,
      name: 'Jun',
      days: 30,
      longName: 'June'
    }, {
      calInt: 6,
      name: 'Jul',
      days: 31,
      longName: 'July'
    }, {
      calInt: 7,
      name: 'Aug',
      days: 31,
      longName: 'August'
    }, {
      calInt: 8,
      name: 'Sep',
      days: 30,
      longName: 'September'
    }, {
      calInt: 9,
      name: 'Oct',
      days: 31,
      longName: 'October'
    }, {
      calInt: 10,
      name: 'Nov',
      days: 30,
      longName: 'November'
    }, {
      calInt: 11,
      name: 'Dec',
      days: 31,
      longName: 'December'
    }
  ]
};

module.exports = DateUtils;


},{}],3:[function(require,module,exports){
var LinearScale;

LinearScale = (function() {
  LinearScale.prototype.domain = [];

  LinearScale.prototype.range = [];

  LinearScale.prototype.dx = 1;

  LinearScale.prototype.dy = 1;

  LinearScale.prototype.m = null;

  LinearScale.prototype.b = null;

  function LinearScale(arg) {
    this.domain = arg.domain, this.range = arg.range;
    this.computeDX();
    this.computeDY();
    this.m = this.dy / this.dx;
    this.b = this.range[0] - (this.m * this.domain[0]);
  }

  LinearScale.prototype.map = function(x) {
    if (this.dx === 0) {
      return this.range[0] + .5 * this.dy;
    } else {
      return this.m * x + this.b;
    }
  };

  LinearScale.prototype.invert = function(y) {
    return (y - this.b) / m;
  };

  LinearScale.prototype.computeDX = function() {
    return this.dx = Math.abs(this.domain[1] - this.domain[0]);
  };

  LinearScale.prototype.computeDY = function() {
    return this.dy = Math.abs(this.range[1] - this.range[0]);
  };

  LinearScale.prototype.getStep = function() {
    var exp, step;
    exp = Math.floor(Math.log(this.dx) / Math.LN10);
    return step = Math.pow(10, exp);
  };

  LinearScale.prototype.ticks = function(minGapInRange) {
    var currentVal, step, ticks;
    if (this.dx === 0) {
      return [this.domain[0]];
    }
    step = this.getStep();
    currentVal = this.domain[0];
    ticks = [];
    while (currentVal <= this.domain[1]) {
      ticks.push(currentVal);
      currentVal = currentVal + step;
    }
    return ticks;
  };

  return LinearScale;

})();

module.exports = LinearScale;


},{}],4:[function(require,module,exports){
var LinearScale, OrdinalScale,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LinearScale = require('./LinearScale.coffee');

OrdinalScale = (function(superClass) {
  extend(OrdinalScale, superClass);

  function OrdinalScale() {
    return OrdinalScale.__super__.constructor.apply(this, arguments);
  }

  OrdinalScale.prototype.domain = [];

  OrdinalScale.prototype.range = [];

  OrdinalScale.prototype.aIsGreater = function(a, b) {
    return a > b;
  };

  OrdinalScale.prototype.computeDX = function() {
    return this.dx = this.domain.length;
  };

  OrdinalScale.prototype.invert = function(y) {
    var closestX, diff, i, len, ref, smallestDiff, x;
    smallestDiff = Infinity;
    closestX = null;
    ref = this.domain;
    for (i = 0, len = ref.length; i < len; i++) {
      x = ref[i];
      if ((diff = Math.abs(this.map(x) - y)) < smallestDiff) {
        smallestDiff = diff;
        closestX = x;
      }
    }
    return closestX;
  };

  OrdinalScale.prototype.map = function(x, linearly) {
    var index;
    if (linearly == null) {
      linearly = false;
    }
    if (linearly) {
      return OrdinalScale.__super__.map.apply(this, arguments);
    } else {
      index = this.domain.indexOf(x);
      return index * this.m;
    }
  };

  OrdinalScale.prototype.positionInDomain = function(x) {
    var index;
    index = this.domain.indexOf(x);
    if (index !== -1) {
      return index;
    } else {
      if (this.aIsGreater(x, _.last(this.domain))) {
        return this.domain.length;
      } else if (this.aIsGreater(this.domain[0], x)) {
        return -1;
      }
    }
  };

  OrdinalScale.prototype.yValueAtZero = function() {
    return this.range[0];
  };

  OrdinalScale.prototype.ticks = function(minGapInRange) {
    return this.domain;
  };

  return OrdinalScale;

})(LinearScale);

module.exports = OrdinalScale;


},{"./LinearScale.coffee":3}],5:[function(require,module,exports){
var Axis, Group, Line, Text;

Text = ReactCanvas.Text, Line = ReactCanvas.Line, Group = ReactCanvas.Group;


/*
Renders the axis for a chart.  See propTypes for description
of how to render x or y axis, place labels, etc.
 */

Axis = React.createClass({
  vert_offset: 10,
  render: function() {
    return React.createElement(Group, null, this.renderLabels(), (this.props.showAxisLine ? this.renderAxisLine() : void 0));
  },
  propTypes: {
    axis: React.PropTypes.string.isRequired,
    direction: React.PropTypes.string.isRequired,
    placement: React.PropTypes.string.isRequired,
    scale: React.PropTypes.object.isRequired,
    offset: React.PropTypes.number,
    otherAxisLength: React.PropTypes.number,
    origin: React.PropTypes.object,
    textStyle: React.PropTypes.object,
    showAxisLine: React.PropTypes.bool,
    axisLineStyle: React.PropTypes.object,
    labelForTick: React.PropTypes.func,
    thickness: React.PropTypes.number
  },
  getDefaultProps: function() {
    return {
      origin: {
        x: 0,
        y: 0
      },
      showAxisLine: true,
      thickness: 100,
      textStyle: {
        lineHeight: 20,
        height: 20,
        fontSize: 12
      },
      offset: 0,
      otherAxisLength: 0,
      axisLineStyle: {},
      labelForTick: function(tick) {
        return tick.toString();
      }
    };
  },
  getInitialState: function() {
    var textAlign;
    textAlign = this.props.axis === 'y' ? this.props.placement === 'left' ? 'right' : 'left' : 'left';
    return {
      textAlign: textAlign
    };
  },
  renderAxisLine: function() {
    var frame, ref, ref1, x0, x1, y0, y1;
    ref = this.projectDomainValue(this.props.scale.domain[0]), x0 = ref[0], y0 = ref[1];
    ref1 = this.projectDomainValue(_.last(this.props.scale.domain)), x1 = ref1[0], y1 = ref1[1];
    frame = {
      x0: x0,
      y0: y0,
      x1: x1,
      y1: y1
    };
    return React.createElement(Line, {
      "frame": frame,
      "style": this.props.axisLineStyle
    });
  },
  renderLabels: function() {
    var baseTextStyle, offsetLeft, offsetTop, ref;
    ref = this.getLabelOffset(), offsetLeft = ref[0], offsetTop = ref[1];
    baseTextStyle = _.clone(this.props.textStyle);
    if (baseTextStyle.textAlign == null) {
      baseTextStyle.textAlign = this.state.textAlign;
    }
    return _.map(this.props.scale.ticks(50), (function(_this) {
      return function(tick, index) {
        var left, ref1, style, top, width;
        ref1 = _this.projectDomainValue(tick), left = ref1[0], top = ref1[1];
        width = _this.props.axis === 'y' ? _this.props.thickness : 100;
        left += offsetLeft;
        top += offsetTop;
        style = _.extend({
          left: left,
          top: top,
          width: width
        }, baseTextStyle);
        return React.createElement(Text, {
          "style": style,
          "key": index
        }, _this.props.labelForTick(tick));
      };
    })(this));
  },

  /*
  Given a value in the domain of the scale, project it to
  pixel values based on the orientation of this axis (x,y) and direction
  (e.g. 'left', 'right',...)
   */
  projectDomainValue: function(tick) {
    var axis, direction, left, origin, placement, projected, ref, scale, top;
    ref = this.props, axis = ref.axis, direction = ref.direction, placement = ref.placement, origin = ref.origin, scale = ref.scale;
    projected = scale.map(tick);
    left = (function() {
      switch (axis) {
        case 'x':
          switch (direction) {
            case 'right':
              return projected + origin.x;
            case 'left':
              return -projected + origin.x;
          }
          break;
        case 'y':
          return origin.x + this.props.otherAxisLength * this.props.offset;
      }
    }).call(this);
    top = (function() {
      switch (axis) {
        case 'y':
          switch (direction) {
            case 'down':
              return projected + origin.y;
            case 'up':
              return -projected + origin.y;
          }
          break;
        case 'x':
          return origin.y - this.props.otherAxisLength * this.props.offset;
      }
    }).call(this);
    return [left, top];
  },
  getLabelOffset: function() {
    var axis, direction, left, origin, placement, ref, top;
    ref = this.props, axis = ref.axis, direction = ref.direction, placement = ref.placement, origin = ref.origin;
    left = (function() {
      switch (axis) {
        case 'x':
          return 0;
        case 'y':
          switch (placement) {
            case 'left':
              return -this.props.thickness - 15;
            case 'right':
              return 15;
          }
      }
    }).call(this);
    top = (function() {
      switch (axis) {
        case 'y':
          return 0;
        case 'x':
          switch (placement) {
            case 'above':
              return 2 * -this.vert_offset;
            case 'below':
              return this.vert_offset;
          }
      }
    }).call(this);
    return [left, top];
  },
  axisNameFontStyle: function() {
    return {
      lineHeight: 30,
      height: 30,
      fontSize: 13
    };
  }
});

module.exports = Axis;


},{}],6:[function(require,module,exports){
var Axis, DateUtils, FontFace, Group, Line, Text, TimeAxis, measureText;

Axis = require('./Axis.cjsx');

DateUtils = require('../util/DateUtils.coffee');

measureText = ReactCanvas.measureText, Line = ReactCanvas.Line, Group = ReactCanvas.Group, Text = ReactCanvas.Text, FontFace = ReactCanvas.FontFace;


/*
Renders a time axis with multiple levels of granularity.  For example,
If days are the smallest grain we can show, it will also render months and years.
"Ticks" denote a position on the axis.  A "Hash" is a vertical line marking the axis.
 */

TimeAxis = React.createClass({
  displayName: 'TimeAxis',
  POSSIBLE_GRAINS: ["hour", "day", "month", "year"],
  PIXELS_BETWEEN_HASHES: 12,
  SMALLEST_HASH_MARK: 15,
  FONT_LARGEST_TIME_AXIS: 13,
  FONT_FACE: FontFace.Default(600),
  KEY_DIVIDER: "::",
  render: function() {
    var axisHashes, axisLabels, ref;
    ref = this.calcShapes(), axisLabels = ref.axisLabels, axisHashes = ref.axisHashes;
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
          opacity: .2
        });
        return React.createElement(Line, {
          "style": style,
          "frame": frame
        });
      };
    })(this));
  },
  renderAxisLine: function() {
    var axisFrame, ref, x, y;
    ref = this.props.origin, x = ref.x, y = ref.y;
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
    var axisHashes, axisLabels, date, dontDrawGroup, dontDrawLabels, epoch, fontRatio, fontSize, grain, group, groupIndex, hash, hashByKey, i, index, innerTicksToDraw, j, k, l, largestTruncation, len, len1, len10, len11, len2, len3, len4, len5, len6, len7, len8, len9, m, maxWidth, n, numRows, numberSkippedInARow, o, outerMostTickGroup, outerTicksToDraw, p, q, r, ref, ref1, ref2, ref3, row, s, t, text, textWidth, tick, tickGroup, tickGroups, tickIndex, ticks, truncateIndex, u, v, widthOfLargest;
    numRows = this.POSSIBLE_GRAINS.length;
    axisLabels = [];
    axisHashes = [];
    tickGroups = [];
    ref = this.POSSIBLE_GRAINS;
    for (row = j = 0, len = ref.length; j < len; row = ++j) {
      grain = ref[row];
      ticks = this.allTicksOnAxisForGrain(grain, this.props.scale);
      if (!ticks) {
        continue;
      }
      row = row + 1;
      group = {
        ticks: ticks,
        grain: grain,
        row: row,
        numRows: numRows
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
      for (m = 0, len3 = ticks.length; m < len3; m++) {
        tick = ticks[m];
        $.extend(tick, {
          row: row,
          grain: grain
        });
        tick.key = this.formatKeyForTick(tick);
      }
    }

    /*
    Figure out the truncationIndex for each group.  This is the level to which
    their label needs to be abbreviated (like "January" --> "Jan" --> "J" --> "").  All ticks in a
    group  will be truncated to the same level of abbreviation, for example... if September needs to be written as
    just "Sep", but "March" can fit fine as it is, we still chop down "March" to "Mar" for consistency.)
     */
    for (o = 0, len4 = tickGroups.length; o < len4; o++) {
      tickGroup = tickGroups[o];
      row = tickGroup.row, numRows = tickGroup.numRows, ticks = tickGroup.ticks;
      dontDrawGroup = function() {
        return tickGroup.dontDrawLabels = true;
      };
      maxWidth = this.props.scale.dy / ticks.length;
      truncateIndex = largestTruncation = 0;
      widthOfLargest = 0;
      if (maxWidth < 3 && !this.isOutermostGroup(tickGroup)) {
        dontDrawGroup();
        continue;
      }
      fontSize = this.FONT_LARGEST_TIME_AXIS;
      fontRatio = fontSize / 12;
      for (tickIndex = p = 0, len5 = ticks.length; p < len5; tickIndex = ++p) {
        tick = ticks[tickIndex];
        if (row === numRows) {
          text = this.formatTimeAxisLabel(tick, 0);
          textWidth = fontRatio * this.getTextMetrics(text, fontSize).lines[0].width;
        } else {
          text = this.formatTimeAxisLabel(tick, truncateIndex);
          while ((textWidth = fontRatio * this.getTextMetrics(text, fontSize).lines[0].width) > (maxWidth * .7)) {
            truncateIndex++;
            text = this.formatTimeAxisLabel(tick, truncateIndex);
          }
        }
        if (textWidth > widthOfLargest) {
          widthOfLargest = textWidth;
        }
        if (truncateIndex > largestTruncation) {
          largestTruncation = truncateIndex;
        }
      }
      if (widthOfLargest === 0) {
        dontDrawGroup();
      } else {
        tickGroup.truncateIndex = largestTruncation;
        tickGroup.widthOfLargest = widthOfLargest;
      }
    }
    while (tickGroups[0].dontDrawLabels && tickGroups[0].dontDrawHashes) {
      tickGroups.splice(0, 1);
    }
    tickGroups = tickGroups.slice(0, 3);
    for (i = q = 0, len6 = tickGroups.length; q < len6; i = ++q) {
      tickGroup = tickGroups[i];
      row = i + 1;
      numRows = tickGroups.length;
      tickGroup.row = row;
      tickGroup.numRows = numRows;
      ref1 = tickGroup.ticks;
      for (r = 0, len7 = ref1.length; r < len7; r++) {
        tick = ref1[r];
        tick.row = row;
        tick.numRows = numRows;
      }
    }
    innerTicksToDraw = [];
    for (groupIndex = s = 0, len8 = tickGroups.length; s < len8; groupIndex = ++s) {
      tickGroup = tickGroups[groupIndex];
      ticks = tickGroup.ticks, row = tickGroup.row, numRows = tickGroup.numRows, truncateIndex = tickGroup.truncateIndex, grain = tickGroup.grain, dontDrawLabels = tickGroup.dontDrawLabels;
      if (dontDrawLabels || (groupIndex === tickGroups.length - 1)) {
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
      ref2 = tickGroup.ticks;
      for (tickIndex = u = 0, len10 = ref2.length; u < len10; tickIndex = ++u) {
        tick = ref2[tickIndex];
        this.addHashMarkFromTick(tick, hashByKey, this.props.scale, false);
      }
      i--;
    }
    outerMostTickGroup = _.last(tickGroups);
    n = 1;
    while (outerMostTickGroup.widthOfLargest * (outerMostTickGroup.ticks.length / n) > this.props.scale.dy * .7) {
      n++;
    }
    numberSkippedInARow = 0;
    outerTicksToDraw = [];
    row = outerMostTickGroup.row, grain = outerMostTickGroup.grain;
    fontSize = this.getFontSize(row, tickGroups.length);
    fontRatio = fontSize / 12;
    ref3 = outerMostTickGroup.ticks;
    for (index = v = 0, len11 = ref3.length; v < len11; index = ++v) {
      tick = ref3[index];
      if (numberSkippedInARow < n && n !== 1 && index !== 0) {
        numberSkippedInARow++;
      } else {
        numberSkippedInARow = 0;
        this.addHashMarkFromTick(tick, hashByKey, this.props.scale, true);
        text = this.formatTimeAxisLabel(tick, outerMostTickGroup.truncateIndex);
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
  allTicksOnAxisForGrain: function(grain, timeScale) {
    var domain, endDate, endEpoch, increment, isOneMonth, isOneYear, newTickDate, numTicks, ref, startDate, startEpoch, ticks;
    domain = timeScale.domain;
    startEpoch = domain[0], endEpoch = domain[1];
    ref = [new Date(domain[0]), new Date(domain[1])], startDate = ref[0], endDate = ref[1];
    ticks = [];
    increment = (function() {
      switch (grain) {
        case "hour":
          if (startDate.getSeconds() !== 0) {
            startDate.setHours(startDate.getHours() + 1);
            startDate.setSeconds(0);
          }
          return (function(_this) {
            return function(tickDate) {
              return tickDate.setHours(tickDate.getHours() + 1);
            };
          })(this);
        case "day":
          return (function(_this) {
            return function(tickDate) {
              return tickDate.setDate(tickDate.getDate() + 1);
            };
          })(this);
        case "month":
          isOneMonth = startDate.getMonth() === endDate.getMonth() && startDate.getFullYear() === endDate.getFullYear();
          if (startDate.getDate() > 15 && !isOneMonth) {
            startDate.setMonth(startDate.getMonth() + 1);
            startDate.setDate(1);
          }
          return (function(_this) {
            return function(tickDate) {
              tickDate.setMonth(tickDate.getMonth() + 1);
              return tickDate.setDate(1);
            };
          })(this);
        case "year":
          isOneYear = startDate.getFullYear() === endDate.getFullYear();
          if (!isOneYear && endDate.getMonth() !== 0) {
            startDate.setFullYear(startDate.getFullYear() + 1);
            startDate.setMonth(0);
            startDate.setDate(1);
          }
          return (function(_this) {
            return function(tickDate) {
              tickDate.setFullYear(tickDate.getFullYear() + 1);
              tickDate.setMonth(0);
              return tickDate.setDate(1);
            };
          })(this);
        default:
          break;
      }
    }).call(this);
    numTicks = 0;
    while (startDate.getTime() <= endEpoch) {
      newTickDate = new Date(startDate.getTime());
      ticks.push({
        date: newTickDate,
        grain: grain
      });
      numTicks++;
      if (numTicks >= 500) {
        return false;
      }
      increment(startDate);
    }
    return ticks;
  },
  isOutermostGroup: function(tickGroup) {
    return tickGroup.row === tickGroup.numRows;
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
  getX: function(shape, timeScale) {
    var centerInPixels, date, epoch, grain, isLabel, middleEpoch, numRows, row, width;
    if (timeScale == null) {
      timeScale = this.props.scale;
    }
    isLabel = this.typeOfShapeFromKey(shape.key) === 'tick';
    if (isLabel) {
      row = shape.row, numRows = shape.numRows, date = shape.date, grain = shape.grain, width = shape.width;
      epoch = date.getTime();
      if (row === numRows) {
        return timeScale.map(epoch) + 5;
      } else {
        middleEpoch = DateUtils.midPointOfGrain(date, grain).getTime();
        centerInPixels = timeScale.map(middleEpoch);
        return centerInPixels - width / 2;
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
    var date, dateObj, day, getDay, getHour, getMonth, grain, isFirstTick, month, numRows, ref, row, val, week, year;
    if (truncateIndex == null) {
      truncateIndex = 0;
    }
    date = tick.date, grain = tick.grain, row = tick.row, numRows = tick.numRows, isFirstTick = tick.isFirstTick;
    ref = dateObj = DateUtils.timeToDateObj(date.getTime()), year = ref.year, month = ref.month, week = ref.week, day = ref.day;
    getMonth = function() {
      var standardMonth;
      standardMonth = DateUtils.MONTH_INFOS[month].name;
      switch (truncateIndex) {
        case 0:
          return DateUtils.MONTH_INFOS[month].longName;
        case 1:
          return standardMonth;
        case 2:
          return standardMonth[0];
        default:
          if (row === numRows) {
            return standardMonth[0];
          } else {
            return "";
          }
      }
    };
    getDay = function() {
      switch (truncateIndex) {
        case 0:
          return moment(date).format("Do");
        case 1:
          return dateObj[grain];
        default:
          return "";
      }
    };
    getHour = function() {
      switch (truncateIndex) {
        case 0:
          return dateObj[grain] + 'hr';
        case 1:
          return dateObj[grain];
        default:
          return "";
      }
    };
    val = (function() {
      switch (grain) {
        case "month":
          return getMonth();
        case "day":
          return getDay();
        case "hour":
          return getHour();
        default:
          switch (truncateIndex) {
            case 0:
              return dateObj[grain];
            default:
              if (row === numRows) {
                return dateObj[grain];
              } else {
                return "";
              }
          }
      }
    })();
    return val.toString();
  },
  formatKeyForTick: function(tick) {
    return ["tick", tick.grain, "" + (tick.date.getTime())].join(this.KEY_DIVIDER);
  },
  formatKeyForHashMark: function(hash) {
    return ["hash", hash.grain, "" + (hash.date.getTime())].join(this.KEY_DIVIDER);
  }
});

module.exports = TimeAxis;


},{"../util/DateUtils.coffee":2,"./Axis.cjsx":5}]},{},[1]);
