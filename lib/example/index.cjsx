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
dataManager  = require './dataManager.coffee'

Index = React.createClass

  render: ->
    if not @state.rowScale or not @state.columnScale
      return <div>Loading...</div>
    <div className = ".example-qpcr">
      <Plate
        rowScale    = @state.rowScale
        columnScale = @state.columnScale
      />
      <FluorChart
        cycleScale  = @state.cycleScale
      />
    </div>

  getInitialState: ->
    rowScale: null
    columnScale: null

  componentDidMount: ->
    dataManager.fetchAll => @didFetchData()

  # setup scales and layout
  didFetchData: ->
    @setState
      rowScale: @getRowScale()
      columnScale: @getColumnScale()
      cycleScale: @getCycleScale()

  getRowScale: ->
    new OrdinalScale
      domain: [1..dataManager.NUM_ROWS]
      range: [0, 300]

  getColumnScale: ->
    new OrdinalScale
      domain: [1..dataManager.NUM_COLUMNS]
      range: [0, 600]

  getCycleScale: ->
    new OrdinalScale
      domain: dataManager.state.results.groups[0].domain
      range: [0, 600]

$ ->
  React.render <Index/>, $('body')[0]