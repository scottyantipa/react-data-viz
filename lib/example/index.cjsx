React        = require 'react'
ReactCanvas  = require 'react-canvas'
Plate        = require './plate.cjsx'
{Surface,
Text}        = ReactCanvas
OrdinalScale = require '../javascripts/util/OrdinalScale.coffee'
dataManager  = require './dataManager.coffee'

Index = React.createClass
  getInitialState: ->
    rowScale: null
    columnScale: null

  render: ->
    if not @state.rowScale or not @state.columnScale
      return <div>Loading...</div>
    <Plate
      rowScale    = @state.rowScale
      columnScale = @state.columnScale
    />

  componentDidMount: ->
    dataManager.fetchAll => @didFetchData()

  # setup scales and layout
  didFetchData: ->
    @setState
      rowScale: @getRowScale()
      columnScale: @getColumnScale()

  getRowScale: ->
    new OrdinalScale
      domain: [1..dataManager.NUM_ROWS]
      range: [0, window.innerHeight]

  getColumnScale: ->
    new OrdinalScale
      domain: [1..dataManager.NUM_COLUMNS]
      range: [0, window.innerWidth;]


$ ->
  React.render <Index/>, $('body')[0]