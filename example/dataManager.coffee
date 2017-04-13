$ = require 'jquery'

###
Responsible for creating/getting/storing data
###
DataManager =
  KEY_SEPARATOR: "|"
  COLON: ":" # used in key formatting
  NUM_COLUMNS: 12
  NUM_ROWS: 8
  NUM_CYCLES: 30
  state:
    results: []

  # just for resting
  fetchAll: (callBack) ->
    $.ajax
      type: "GET"
      url: "./data/qpcrGenData.json"
      success: (results) =>
        @parseResults results
        callBack()
      error: (results) ->
        console.warn "error loading qpcr data: ", results

  parseResults: (resultsByWell) ->
    resultsByCycle = {}
    minCycle = 1
    maxCycle = 30
    minFluor = Infinity
    maxFluor = -Infinity
    for wellKey, results of resultsByWell
      for {cycle, fluorescense} in results
        if cycle < minCycle then minCycle = cycle
        if cycle > maxCycle then maxCycle = cycle
        if fluorescense < minFluor then minFluor = fluorescense
        if fluorescense > maxFluor then maxFluor = fluorescense
        if not resultsByCycle["#{cycle}"]
          resultsByCycle[cycle] = []
        resultsByCycle["#{cycle}"].push {wellKey, fluorescense}



    @state.results =
      groups: [

          name: "cycle"
          domain: [minCycle..maxCycle]
        ,

          name: "well"
          domain: [1..96]

      ]

      projections: [
        name: "fluorescense"
        domain: [minFluor, maxFluor]
      ]

      resultsByWell: resultsByWell
      resultsByCycle: resultsByCycle


  keyForWell: (row, column) ->
    "row:#{row}||column:#{column}"

  wellFromKey: (wellKey) ->
    getNum = (str) => parseInt str.split(":")[1]
    [rowStr, columnStr] = wellKey.split "||"

    row: getNum rowStr
    column: getNum columnStr

  # returns a number between 1 and the total number of wells
  wellFlatIndex: (row, column) ->
    (row - 1) * @NUM_COLUMNS + column

module.exports = DataManager
