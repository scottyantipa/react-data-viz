TimeSeriesChart   = require './TimeSeriesChart.cjsx'
QPCRDashboard     = require './QPCRDashboard.cjsx'
StatefulSmokeTest = require './StatefulSmokeTest.cjsx'

Index = React.createClass

  render: ->
    <div>
      {@renderChartOptions()}
      {@renderBody()}
    </div>

  displayName: 'Index'

  getInitialState: ->
    chartToShow: 'QPCRDashboard' # QPCRDashboard, TimeSeriesChart, or StatefulSmokeTest

  renderBody: ->
    switch @state.chartToShow
      when 'QPCRDashboard'
        <QPCRDashboard/>
      when 'TimeSeriesChart'
        <TimeSeriesChart/>
      when 'StatefulSmokeTest'
        <StatefulSmokeTest/>


  renderChartOptions: ->
    <div>

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
  React.render <Index/>, $('body')[0]