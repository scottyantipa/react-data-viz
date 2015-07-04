(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ReactDataViz;

ReactDataViz = {
  LinearScale: require('./javascripts/util/LinearScale.coffee'),
  OrdinalScale: require('./javascripts/util/OrdinalScale.coffee'),
  Axis: require('./javascripts/views/Axis.cjsx'),
  TimeAxis: require('./javascripts/views/TimeAxis.cjsx')
};

window.ReactDataViz = ReactDataViz;
},{"./javascripts/util/LinearScale.coffee":2,"./javascripts/util/OrdinalScale.coffee":3,"./javascripts/views/Axis.cjsx":4,"./javascripts/views/TimeAxis.cjsx":5}],2:[function(require,module,exports){
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
    return this.m * x + this.b;
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

  LinearScale.prototype.ticks = function() {
    var currentVal, step, ticks;
    step = this.getStep();
    currentVal = this.domain[0];
    ticks = [];
    while (currentVal < this.domain[1]) {
      ticks.push(currentVal);
      currentVal = currentVal + step;
    }
    return ticks;
  };

  return LinearScale;

})();

module.exports = LinearScale;


},{}],3:[function(require,module,exports){
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


},{"./LinearScale.coffee":2}],4:[function(require,module,exports){
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
      axisLineStyle: {},
      labelForTick: function(tick) {
        return tick.toString();
      }
    };
  },
  getInitialState: function() {
    var textAlign;
    textAlign = this.props.axis === 'y' ? this.props.placement === 'left' ? 'right' : 'left' : 'center';
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
        width = _this.props.thickness;
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
          return origin.x;
      }
    })();
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
          return origin.y;
      }
    })();
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
              return this.props.thickness + 15;
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


},{}],5:[function(require,module,exports){
var Axis, TimeAxis;

Axis = require('./Axis.cjsx');

TimeAxis = React.createClass({
  render: function() {
    var axis, axisLineStyle, axisName, direction, origin, placement, ref, scale, textStyle;
    ref = this.props, axisName = ref.axisName, scale = ref.scale, axis = ref.axis, placement = ref.placement, direction = ref.direction, origin = ref.origin, textStyle = ref.textStyle, axisLineStyle = ref.axisLineStyle;
    return React.createElement(Axis, {
      "axisName": axisName,
      "origin": origin,
      "labelForTick": this.labelForTick,
      "scale": scale,
      "axis": axis,
      "placement": placement,
      "direction": direction,
      "textStyle": textStyle,
      "axisLineStyle": axisLineStyle
    });
  },
  displayName: 'TimeAxis',
  getInitialState: function() {
    var day, hour, minute, month, ref, step, timeFormat, timeLabel, year;
    step = this.props.scale.getStep();
    ref = step < (minute = 1000 * 60) ? ['ss', 's'] : step < (hour = minute * 60) ? ['mm', 'm'] : step < (day = hour * 24) ? ['hh', 'h'] : step < (month = day * 30) ? ['DD', 'd'] : step < (year = month * 12) ? ['MMMM', ''] : void 0, timeFormat = ref[0], timeLabel = ref[1];
    return {
      timeFormat: timeFormat,
      timeLabel: timeLabel
    };
  },
  labelForTick: function(epoch) {
    var time;
    time = moment(epoch).format(this.state.timeFormat);
    return "" + time + this.state.timeLabel;
  }
});

module.exports = TimeAxis;


},{"./Axis.cjsx":4}]},{},[1]);
