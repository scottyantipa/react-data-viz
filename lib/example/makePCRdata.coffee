fs          = require 'fs'
dataManager = require './dataManager'

# NOTE THAT THESE CONSTANTS ARE REUSED
# IN dataManager and should be abstracted elsewhere
KEY_SEPARATOR = "|"
COLON = ":" # used in key formatting
NUM_COLUMNS = 12
NUM_ROWS = 8
NUM_CYCLES = 30
MAX_FLUOR = 5000
MIN_FLUOR = 0

resultsByWellKey = {}

numWellsCreated = 0
for row in [1..NUM_ROWS]
  for column in [1..NUM_COLUMNS]
    numWellsCreated++
    # continue if numWellsCreated < 20 or numWellsCreated > 100
    logFnc = (x) ->
      k = .3 * column
      5000 / (1 + Math.pow(Math.E, -k*(x - ((200 * row) + (6 * column)) / 80)))

    wellKey = dataManager.keyForWell row, column

    resultsByWellKey[wellKey] ?= []
    i = 1
    while i <= 40
      resultsByWellKey[wellKey].push
        cycle: i
        fluorescense: Math.floor (logFnc(i) * 100) / 100
      i++

fs.writeFile __dirname + '/../../public/data/qpcrGenData.json', JSON.stringify(resultsByWellKey)
