var OrdinalScale, Scale, _,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('underscore');

Scale = require('./Scale');

OrdinalScale = (function(superClass) {
  extend(OrdinalScale, superClass);

  function OrdinalScale(arg) {
    this.domain = arg.domain, this.range = arg.range;
    this.dx = this.domain.length;
    this.setup();
  }

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

  OrdinalScale.prototype.invert = function(y) {
    var closestX, diff, i, len, ref, smallestDiff, x;
    smallestDiff = 2e308;
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

  OrdinalScale.prototype.positionInDomain = function(x) {
    var index;
    index = this.domain.indexOf(x);
    if (index !== -1) {
      return index;
    } else {
      if (x > _.last(this.domain)) {
        return this.domain.length;
      } else if (this.domain[0] > x) {
        return -1;
      }
    }
  };

  OrdinalScale.prototype.yValueAtZero = function() {
    return this.range[0];
  };

  OrdinalScale.prototype.ticks = function() {
    return this.domain;
  };

  return OrdinalScale;

})(Scale);

module.exports = OrdinalScale;
