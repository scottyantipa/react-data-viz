// This currently exports ReactDataViz, ReactCanvas, and React.
// We do this, instead of purely using requires, so that
// Packages dependent on ReactDataViz can include them as
// a standard script rather than through require.

// ReactCanvas depends on a specific versin of React.
// Packages dependent on ReactDataViz should use this
// build of React as well.
window.React = require('react/addons');

// ReactCanvas is directly referenced in the ReactDataViz modules
window.ReactCanvas = require('react-canvas');

window.ReactDataViz = {
  LinearScale: require('./javascripts/util/LinearScale.coffee'),
  OrdinalScale: require('./javascripts/util/OrdinalScale.coffee'),
  Axis: require('./javascripts/views/Axis.cjsx'),
  TimeAxis: require('./javascripts/views/TimeAxis.cjsx')
};
