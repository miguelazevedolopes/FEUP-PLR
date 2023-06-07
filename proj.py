from ortools.sat.python import cp_model


def aircraft_landing():
    # Read data from the file
    # with open('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt', 'r') as file:
    with open('/Users/mafalda/Documents/FEUP/PLR/FEUP-PLR/airland1.txt', 'r') as file:
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

    # print("Appearence Times :")
    # print(appearance_times)
    # print("Earliest Landing Times :")
    # print(earliest_landing_times)
    # print("Target Landing Times :")
    # print(target_landing_times)
    # print("Latest Landing Times :")
    # print(latest_landing_times)
    # print("Penalty Before :")
    # print(penalty_before)
    # print("Penalty After :")
    # print(penalty_after)
    # print("Separation Times :")
    # print(separation_times)

    model = cp_model.CpModel()
    landing_times = [model.NewIntVar(0, max(latest_landing_times), f"LandingTime{i+1}") for i in range(number_planes)]
    
    # Earliest and latest landing times constraints
    for i in range(number_planes):
        model.Add(landing_times[i] >= earliest_landing_times[i])
        model.Add(landing_times[i] <= latest_landing_times[i])
    
    # Separation constraints
    for i in range(number_planes):
        for j in range(number_planes):
            if i != j:
                model.Add(landing_times[i] >= landing_times[j] + separation_times[i][j])
                model.Add(landing_times[j] >= landing_times[i] + separation_times[j][i])

    times_before = [model.NewIntVar(0, target_landing_times[i] - earliest_landing_times[i], f"TimesBefore{i+1}") for i in range(number_planes)]
    times_after = [model.NewIntVar(0, latest_landing_times[i] - target_landing_times[i], f"TimesAfter{i+1}") for i in range(number_planes)]
    
    # Time before and after target constraint
    for i in range(number_planes):
        model.Add(times_before[i] + times_after[i] == landing_times[i] - target_landing_times[i])

    # Objective function
    objective_expr = sum(
        penalty_before[i] * times_before[i] + penalty_after[i] * times_after[i]
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
        print("Times After:", [solver.Value(times_after[i]) for i in range(number_planes)])
        print("Times Before:", [solver.Value(times_before[i]) for i in range(number_planes)])
        print("Execution Time:", solver.WallTime())
    else:
        print("No solution found.")


# Run the function
aircraft_landing()