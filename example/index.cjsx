$ = require 'jquery'
window.ReactDataViz = require '../lib/index.js'

React = require 'react'
createReactClass = require 'create-react-class'
ReactDOM = require 'react-dom'

TimeSeriesChart   = require './TimeSeriesChart.cjsx'
QPCRDashboard     = require './QPCRDashboard.cjsx'
StatefulSmokeTest = require './StatefulSmokeTest.cjsx'

Index = createReactClass

  render: ->
    <div className = 'app'>
      {@renderChartOptions()}
      {@renderBody()}
    </div>

  displayName: 'Index'

  getInitialState: ->
    chartToShow: 'TimeSeriesChart' # QPCRDashboard, TimeSeriesChart, or StatefulSmokeTest

  renderBody: ->
    switch @state.chartToShow
      when 'QPCRDashboard'
        <QPCRDashboard/>
      when 'TimeSeriesChart'
        <TimeSeriesChart/>
      when 'StatefulSmokeTest'
        <StatefulSmokeTest/>


  renderChartOptions: ->
    <div className = 'chart-options'>

      <button
        onClick = { => @setState chartToShow: 'QPCRDashboard'}
      >
        QPCRDashboard
      </button>

      <button
        onClick = {=> @setState chartToShow: 'TimeSeriesChart'}
      >
        TimeSeriesChart
      </button>

      <button
        onClick = {=> @setState chartToShow: 'StatefulSmokeTest'}
      >
        StatefulSmokeTest
      </button>

    </div>


$ ->
  ReactDOM.render <Index/>, $('#app')[0]
