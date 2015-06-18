TimeSeriesChart = require './TimeSeriesChart.cjsx'
QPCRDashboard   = require './QPCRDashboard.cjsx'

Index = React.createClass

  render: ->
    <div>
      {@renderChartOptions()}
      {@renderBody()}
    </div>

  displayName: 'Index'

  getInitialState: ->
    chartToShow: 'timeline' # qpcr or timeline

  renderBody: ->
    switch @state.chartToShow
      when 'qpcr'
        <QPCRDashboard/>
      when 'timeline'
        <TimeSeriesChart/>


  renderChartOptions: ->
    <div>

      <button
        onClick = { => @setState chartToShow: 'qpcr'}
      >
        qPCR Dashboard
      </button>

      <button
        onClick = {=> @setState chartToShow: 'timeline'}
      >
        Timeline
      </button>

    </div>


$ ->
  React.render <Index/>, $('body')[0]