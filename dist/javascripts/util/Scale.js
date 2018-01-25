var Scale;

Scale = (function() {
  function Scale() {}

  Scale.prototype.domain = [];

  Scale.prototype.range = [];

  Scale.prototype.dx = 1;

  Scale.prototype.dy = 1;

  Scale.prototype.m = null;

  Scale.prototype.b = null;

  Scale.prototype.setup = function() {
    this.dy = this.diffInRange(this.range);
    this.m = this.dy / this.dx;
    return this.b = this.computeIntercept();
  };

  Scale.prototype.map = function(x) {
    if (this.dx === 0) {
      return this.range[0] + .5 * this.dy;
    } else {
      return this.m * x + this.b;
    }
  };

  Scale.prototype.invert = function(y) {
    return (y - this.b) / this.m;
  };

  Scale.prototype.diffInRange = function(rangeDelta) {
    return Math.abs(rangeDelta[1] - rangeDelta[0]);
  };

  Scale.prototype.computeIntercept = function() {
    return this.range[0] - (this.m * this.domain[0]);
  };

  Scale.prototype.getStep = function(domainDelta) {
    var exp;
    exp = Math.floor(Math.log10(domainDelta));
    return Math.pow(10, exp);
  };

  Scale.prototype.ticks = function(minGapInRange) {
    var currentVal, step, ticks;
    if (this.dx === 0) {
      return [this.domain[0]];
    }
    step = this.getStep(this.dx);
    currentVal = this.domain[0];
    ticks = [];
    while (currentVal <= this.domain[1]) {
      ticks.push(currentVal);
      currentVal = currentVal + step;
    }
    return ticks;
  };

  return Scale;

})();

module.exports = Scale;
