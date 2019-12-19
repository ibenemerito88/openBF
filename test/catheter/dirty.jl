using Revise
using openBF
data = openBF.loadSimulationFiles("catheter.yml")
blood = openBF.buildBlood(data["blood"])
jump = data["solver"]["jump"]
vessels, edges = openBF.buildArterialNetwork(data["network"], blood, jump)
openBF.makeResultsFolder(data)
Ccfl = data["solver"]["Ccfl"]
heart = vessels[1].heart
total_time = data["solver"]["cycles"]*heart.cardiac_T
timepoints = range(0, stop=heart.cardiac_T, length=jump)
current_time = 0.0
passed_cycles = 0
counter = 1


        dt = openBF.calculateDeltaT(vessels, Ccfl)
        openBF.solveModel(vessels, edges, blood, dt, current_time)
        openBF.updateGhostCells(vessels)

        if current_time >= timepoints[counter]
            openBF.saveTempData(current_time, vessels, counter)
            counter += 1
        end

        if (current_time - heart.cardiac_T*passed_cycles) >= heart.cardiac_T &&
          (current_time - heart.cardiac_T*passed_cycles + dt) > heart.cardiac_T

            if passed_cycles + 1 > 1
                err = openBF.checkConvergence(edges, vessels)
                
                    if err > 100.0
                        println("\n - Conv. error > 100%%\n")
                    else
                        println("\n - Conv. error = %4.2f%%\n", err)
                    end
                
            else
                err = 100.0
               
            end

            openBF.transferTempToLast(vessels)

            openBF.out_files && openBF.transferLastToOut(vessels)

            if err <= data["solver"]["convergence tolerance"]
                println("\nOver convergence tolerance")
            end

            passed_cycles += 1
            println("\nSolving cardiac cycle no: %d", passed_cycles + 1)

            timepoints = timepoints .+ heart.cardiac_T
            counter = 1
        end

        current_time += dt
        if current_time >= total_time
            passed_cycles += 1
            println("\nNot converged after $passed_cycles cycles, End!")
        end

    cd("..")

