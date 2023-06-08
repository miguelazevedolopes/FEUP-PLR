from ortools.sat.python import cp_model


def aircraft_landing():
    # Read data from the file
    # with open('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt', 'r') as file:
    with open('airland1_copy.txt', 'r') as file:
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
    landing_times = [model.NewIntVar(earliest_landing_times[i], latest_landing_times[i], f"LandingTime{i+1}") for i in range(number_planes)]

    # Earliest and latest landing times constraints
    # Each plane must land within its specified time window: Ei ≤ xi ≤ Li for all planes i.
    # for i in range(number_planes):
    #     model.Add(landing_times[i] >= earliest_landing_times[i])
    #     model.Add(landing_times[i] <= latest_landing_times[i])

    model.AddAllDifferent(landing_times)


#   For each pair of planes (i, j), either plane i lands before plane j (δij = 1) or plane j lands before plane i (δji = 1).
#   There are three sets of plane pairs:
#       a) Set W: i must land before j (Li < Ej) and the separation constraint is automatically satisfied (Li + Sij ≤ Ej).
#        b) Set V: i must land before j (Li < Ej), but the separation constraint is not automatically satisfied (Li + Sij > Ej).
#       c) Set U: pairs with overlapping time windows where uncertainty exists about the order of landing.
#   δij = 1 for all pairs (i, j) in set W or V.
#   Separation constraint for pairs in set V: xj ≥ xi + Sij.
#   Separation constraint for pairs in set U: xj ≥ xi + Sij - (Li + Sij - Ej)δji.
    
    is_before = []
    is_after = []

    for i in range(number_planes):
        current_before = []
        current_after = []

        for j in range(number_planes):
            current_before.append(model.NewIntVar(0, 1, f"before_{i}_{j}"))
            current_after.append(model.NewIntVar(0, 1, f"after_{i}_{j}"))

        is_before.append(current_before)
        is_after.append(current_after)

    for i in range(number_planes):
        for j in range(number_planes):
            if i != j:
                model.Add(is_before[i][j] + is_after[i][j] == 1)
                model.Add(is_before[i][j] + is_before[j][i] == 1)
                model.Add(is_after[i][j] + is_after[j][i] == 1)
            else:
                model.Add(is_before[i][j] == 0)
                model.Add(is_after[i][j] == 0)
    
    # print("Model -", model)

    # Separation constraints
    for i in range(number_planes):
        for j in range(i+1, number_planes):
            # i must land before j
            if latest_landing_times[i] < earliest_landing_times[j]:
                model.Add(landing_times[j] >= landing_times[i] + separation_times[i][j])
            # If the time windows of i and j overlap, ensure separation time is met
            else:
                model.Add((landing_times[i] * is_after[i][j]) + (landing_times[j] * is_after[j][i]) >= separation_times[i][j] + (landing_times[i] * is_before[i][j]) + (landing_times[j] * is_before[j][i]))



                
    # print("Model - ", model)

    time_before = [model.NewIntVar(0, target_landing_times[i] - earliest_landing_times[i], f"TimesBefore{i+1}") for i in range(number_planes)]
    time_after = [model.NewIntVar(0, latest_landing_times[i] - target_landing_times[i], f"TimesAfter{i+1}") for i in range(number_planes)]

    # print("Model - ", model)
    
    # Time before and after target constraint
    for i in range(number_planes):
        model.AddAbsEquality(time_before[i] + time_after[i], landing_times[i] - target_landing_times[i])
        # model.Add(time_before[i] + time_after[i] == landing_times[i] - target_landing_times[i])

    # print("Model - ", model)

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