var ReactDataViz;

ReactDataViz = {
  LinearScale: require('./javascripts/util/LinearScale.coffee'),
  OrdinalScale: require('./javascripts/util/OrdinalScale.coffee'),
  Axis: require('./javascripts/views/Axis.cjsx')
};

window.ReactDataViz = ReactDataViz;