{Surface,
Group,
Text,
Layer,
Point,
Text}        = ReactCanvas
Plate        = require './plate.cjsx'
FluorChart   = require './FluorChart.cjsx'
dataManager  = require './dataManager.coffee'

QPCRDashboard = React.createClass
  displayName: 'QPCRDashboard'
  render: ->
    if not @state.fetched
      return <div>Loading...</div>
    <div className = 'example-qpcr'>
      {@renderFluorChart()}
      {@renderPlate()}
    </div>

  renderPlate: ->
    <div className = 'pcr-plate'>
      <Plate
        numRows    = dataManager.NUM_ROWS
        numColumns = dataManager.NUM_COLUMNS
      />
    </div>

  renderFluorChart: ->
    {results} = dataManager.state
    <div className = 'pcr-line-chart'>
      <FluorChart
        cycleResults  = results.groups[0]
        fluorResults  = results.projections[0]
        resultsByWell = results.resultsByWell
      />
    </div>

  getInitialState: ->
    fetched: false

  componentDidMount: ->
    dataManager.fetchAll => @setState fetched: true

module.exports = QPCRDashboard