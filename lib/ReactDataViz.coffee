ReactDataViz =
  LinearScale: require './javascripts/util/LinearScale.coffee'
  OrdinalScale: require './javascripts/util/OrdinalScale.coffee'

  Axis:    require './javascripts/views/Axis.cjsx'
  Line:    require '../node_modules/react-canvas/lib/Line.js'
  Point:   require '../node_modules/react-canvas/lib/Point.js'
  Surface: require '../node_modules/react-canvas/lib/Surface.js'

window.ReactDataViz = ReactDataViz