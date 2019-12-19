using Revise
using openBF
data = openBF.loadSimulationFiles("catheter.yml")
blood = openBF.buildBlood(data["blood"])
jump = data["solver"]["jump"]
vessels, edges = openBF.buildArterialNetwork(data["network"], blood, jump)

Ccfl = data["solver"]["Ccfl"]
heart = vessels[1].heart
total_time = data["solver"]["cycles"]*heart.cardiac_T
timepoints = range(0, stop=heart.cardiac_T, length=jump)

