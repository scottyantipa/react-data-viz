var Axis, Group, Line, React, Text, _, ref;

_ = require('underscore');

ref = require('react-canvas'), Text = ref.Text, Line = ref.Line, Group = ref.Group;

React = require('react');


/*
Renders the axis for a chart.  See propTypes for description
of how to render x or y axis, place labels, etc.
 */

Axis = React.createClass({displayName: "Axis",
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
    var frame, ref1, ref2, x0, x1, y0, y1;
    ref1 = this.projectDomainValue(this.props.scale.domain[0]), x0 = ref1[0], y0 = ref1[1];
    ref2 = this.projectDomainValue(_.last(this.props.scale.domain)), x1 = ref2[0], y1 = ref2[1];
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
    var baseTextStyle, offsetLeft, offsetTop, ref1;
    ref1 = this.getLabelOffset(), offsetLeft = ref1[0], offsetTop = ref1[1];
    baseTextStyle = _.clone(this.props.textStyle);
    if (baseTextStyle.textAlign == null) {
      baseTextStyle.textAlign = this.state.textAlign;
    }
    return _.map(this.props.scale.ticks(50), (function(_this) {
      return function(tick, index) {
        var left, ref2, style, top, width;
        ref2 = _this.projectDomainValue(tick), left = ref2[0], top = ref2[1];
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
    var axis, direction, left, origin, placement, projected, ref1, scale, top;
    ref1 = this.props, axis = ref1.axis, direction = ref1.direction, placement = ref1.placement, origin = ref1.origin, scale = ref1.scale;
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
    var axis, direction, left, origin, placement, ref1, top;
    ref1 = this.props, axis = ref1.axis, direction = ref1.direction, placement = ref1.placement, origin = ref1.origin;
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
