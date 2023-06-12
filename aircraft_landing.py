from ortools.sat.python import cp_model


def aircraft_landing():
    # Read data from the file
    with open('data/airland3.txt', 'r') as file:
        lines = file.readlines()

    # Extract values from the first line
    first_line = lines[0].split()
    number_planes = int(first_line[0])
    freeze_time = int(first_line[1])

    # Extract values from the remaining lines                                                                                                                                                   
    appearance_times = []
    earliest_landing_times = []
    target_landing_times = []
    latest_landing_times = []
    penalty_before = []
    penalty_after = []
    separation_times = []
    current_line = 2

    for line in lines[1:]:
        values = list(map(int, line.split()))
        if(current_line % 2 == 0):
            appearance_times.append(values[0])
            earliest_landing_times.append(values[1])
            target_landing_times.append(values[2])
            latest_landing_times.append(values[3])
            penalty_before.append(values[4])
            penalty_after.append(values[5])
        else:
            separation_times.append(values)
        
        current_line+=1

    # Create the model
    model = cp_model.CpModel()

    # Add Landing Times variable which has the domain [earliest_landing_times, latest_landing_times]
    landing_times = [model.NewIntVar(earliest_landing_times[i], latest_landing_times[i], f"LandingTime{i+1}") for i in range(number_planes)]

    # Add constraint that the landing times must be all different
    model.AddAllDifferent(landing_times)
    
    # Add new Bool Variable that is true if landing_times[i] < landing_times[j]
    is_before = []

    for i in range(number_planes):
        current_before = []

        for j in range(number_planes):
            current_before.append(model.NewBoolVar(f"before_{i}_{j}"))

        is_before.append(current_before)

    # Separation constraints
    for i in range(number_planes):
        for j in range(i, number_planes):
            if i != j:
                # i must land before j
                if latest_landing_times[i] < earliest_landing_times[j]:
                    model.Add(landing_times[j] >= landing_times[i] + separation_times[i][j])
                    
                # If the time windows of i and j overlap, ensure separation time is met
                else:
                    model.Add(landing_times[i] >= landing_times[j] + separation_times[j][i]).OnlyEnforceIf(is_before[j][i])
                    model.Add(landing_times[j] >= landing_times[i] + separation_times[i][j]).OnlyEnforceIf(is_before[i][j])

                    model.AddExactlyOne([is_before[j][i], is_before[i][j]])

    time_before = [model.NewIntVar(0, target_landing_times[i] - earliest_landing_times[i], f"TimesBefore{i+1}") for i in range(number_planes)]
    time_after = [model.NewIntVar(0, latest_landing_times[i] - target_landing_times[i], f"TimesAfter{i+1}") for i in range(number_planes)]
    
    # Time before and after target constraint
    for i in range(number_planes):
        model.AddAbsEquality(time_before[i] + time_after[i], landing_times[i] - target_landing_times[i])

    # Objective function
    objective_expr = sum(
        penalty_before[i] * time_before[i] + penalty_after[i] * time_after[i]
        for i in range(number_planes)
    )
    model.Minimize(objective_expr)

    solver = cp_model.CpSolver()
    solver.parameters.max_time_in_seconds = 600
    status = solver.Solve(model)

    if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
        landing_time_values = [solver.Value(landing_times[i]) for i in range(number_planes)]
        print("Landing Times:", landing_time_values)
        print("Sum:", solver.ObjectiveValue())
        print("Times After:", [solver.Value(time_after[i]) for i in range(number_planes)])
        print("Times Before:", [solver.Value(time_before[i]) for i in range(number_planes)])
        print("Execution Time:", solver.WallTime())
    elif status == cp_model.INFEASIBLE:
        model_proto = model.Proto()
        print(model_proto)
        print("Infeasible")
    elif status == cp_model.MODEL_INVALID:
        print("Model Invalid")
    else:
        print("No solution found.")


# Run the function
aircraft_landing()