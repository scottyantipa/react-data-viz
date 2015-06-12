{Surface,
Group,
Text,
Layer,
Point,
Text}        = require 'react-canvas'
React        = require 'react'
Plate        = require './plate.cjsx'
FluorChart   = require './FluorChart.cjsx'
dataManager  = require './dataManager.coffee'

Index = React.createClass

  render: ->
    if not @state.fetched
      return <div>Loading...</div>

    <div className = 'example-qpcr'>
      {@renderPlate()}
      {@renderFluorChart()}
    </div>

  renderPlate: ->
    <div className = 'pcr-plate'>
      <Plate
        numRows    = dataManager.NUM_ROWS
        numColumns = dataManager.NUM_COLUMNS
      />
    </div>

  renderFluorChart: ->
    <div className = 'pcr-line-chart'>
      <FluorChart
        cycleResults = dataManager.state.results.groups[0]
        fluorResults = dataManager.state.results.projections[0]
      />
    </div>

  getInitialState: ->
    fetched: false

  componentDidMount: ->
    dataManager.fetchAll => @setState fetched: true

$ ->
  React.render <Index/>, $('body')[0]