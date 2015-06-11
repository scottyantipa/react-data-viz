{Surface,
Group,
Text,
Layer,
Point,
Text}        = require 'react-canvas'
React        = require 'react'
Plate        = require './plate.cjsx'
FluorChart   = require './FluorChart.cjsx'
OrdinalScale = require '../javascripts/util/OrdinalScale.coffee'
LinearScale  = require '../javascripts/util/LinearScale.coffee'
dataManager  = require './dataManager.coffee'

Index = React.createClass

  render: ->
    if not _.all([@state.rowScale, @state.columnScale, @state.cycleScale, @state.fluorScale])
      return <div>Loading...</div>
    <div className = 'example-qpcr'>
      {@renderFluorChart()}
    </div>

  renderPlate: ->
    <div className = 'pcr-plate'>
      <Plate
        rowScale    = @state.rowScale
        columnScale = @state.columnScale
      />
    </div>

  renderFluorChart: ->
    <div className = 'pcr-line-chart'>
      <FluorChart
        cycleScale  = @state.cycleScale
        fluorScale  = @state.fluorScale
      />
    </div>

  getInitialState: ->
    rowScale:    null
    columnScale: null
    cycleScale:  null
    fluorScale:  null

  componentDidMount: ->
    dataManager.fetchAll => @didFetchData()

  # setup scales and layout
  didFetchData: ->
    @setState
      rowScale: @getRowScale()
      columnScale: @getColumnScale()
      cycleScale: @getCycleScale()
      fluorScale: @getFluorScale()

  #
  # Plate scales
  #
  getRowScale: ->
    new OrdinalScale
      domain: [1..dataManager.NUM_ROWS]
      range: [0, 300]
  getColumnScale: ->
    new OrdinalScale
      domain: [1..dataManager.NUM_COLUMNS]
      range: [0, window.innerWidth - 100]

  #
  # qPCR line scales
  #
  getCycleScale: ->
    new OrdinalScale
      domain: dataManager.state.results.groups[0].domain
      range: [0, window.innerWidth - 100]
  getFluorScale: ->
    new LinearScale
      domain: dataManager.state.results.projections[0].domain
      range: [0, 300]

$ ->
  React.render <Index/>, $('body')[0]