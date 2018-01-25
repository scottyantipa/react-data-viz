var LinearScale, Scale,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Scale = require('./Scale');

LinearScale = (function(superClass) {
  extend(LinearScale, superClass);

  function LinearScale(arg) {
    var dx, roundDomain, step;
    this.domain = arg.domain, this.range = arg.range, roundDomain = arg.roundDomain;
    if (roundDomain) {
      dx = this.diffInRange(this.domain);
      if (dx !== 0) {
        step = this.getStep(dx);
        this.domain = [Math.floor(this.domain[0] / step) * step, Math.ceil(this.domain[1] / step) * step];
      }
    }
    this.dx = this.diffInRange(this.domain);
    this.setup();
  }

  return LinearScale;

})(Scale);

module.exports = LinearScale;
