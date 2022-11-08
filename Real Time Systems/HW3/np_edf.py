
# NP_EDF.py
# Non-Preemptive EDF execution generator
# Author: Calvin Spencer

import json
import sys
import numpy as np

# Makes a 2d data structure with each job to be completed
def gen_jobs(tasks, min_n, max_n, max_t):
    jobs = [[] for i in range(max_n+1)]
    for i in range(min_n, max_n + 1):
        tasks[i]["n_jobs"] = int(np.ceil((max_t - tasks[i]["phase"]) / tasks[i]["period"]))
        for job in range(tasks[i]["n_jobs"]):
            jobs[tasks[i]["num"]].append({
                "task": i,
                "num": job,
                "release":  tasks[i]["phase"] + (job * tasks[i]["period"]),
                "deadline": tasks[i]["phase"] + (job * tasks[i]["period"]) + tasks[i]["deadline"],
                "c": tasks[i]["c"],
                "remaining_c": tasks[i]["c"]
            })
    return jobs

# Aligns the indexes of each task to the task num
def alignIndexes(tasks, max_n):
    new_tasks = [[]]*(max_n+1)
    
    for task in tasks:
        new_tasks[task["num"]] = task
    return new_tasks

# Find largest index task num
def findMaxTaskNum(tasks):
    max_n = -1
    for task in tasks:
        if (task["num"] > max_n):
            max_n = task["num"]
    return max_n

# Find lowest index task num
def findMinTaskNum(tasks):
    min_n = float('inf')
    for task in tasks:
        if (task["num"] < min_n):
            min_n = task["num"]
    return min_n

# Add an execution job to out_data
def addExecution(out_data, task, job_n, start, end):
    
    job = {}
    job['taskNum'] = task
    job['jobNum'] = job_n
    job['start'] = start
    job['end'] = end
    out_data['executions'].append(job)
    return (out_data)

def main():
    if len(sys.argv) < 3:
        print("Missing argument.")
        print("Usage: EDF.py <input.json> <output.json>")
        sys.exit(1)

    # Read input data
    with open(sys.argv[1]) as in_file:    
        in_data = json.load(in_file)
    tasks = in_data["tasks"]
    # Sort by task number?
    max_t = in_data["max_t"]
    
    n_tasks = len(tasks)
    
    # Create and initialize dictionary for output data
    out_data = {}
    out_data['max_t'] = max_t

    # Create empty list of executions
    out_data['executions'] = []
    # add tasks to out data
    out_data['tasks'] = tasks
    
    # Bounds of the number of tasks (unspecified if starts at 0 or 1)
    max_n = findMaxTaskNum(tasks)
    min_n = findMinTaskNum(tasks)
    
    # tasks[1] ~ tasks["num"] == 1
    tasks = alignIndexes(tasks, max_n)
    
    # Generate 2d array of jobs (tasks x job #)
    jobs = gen_jobs(tasks, min_n, max_n, max_t)
    
    # Remaining execution (cannot preempt)
    c_remaining = -1
    
    # For each time unit
    for t in range(max_t + 1):
        # If computation is still executing, skip adding any jobs 
        if (c_remaining > 0):
            c_remaining -= 1
            continue
        # If all jobs are done executing, look for a job to execute
        else:
            consider_jobs = []

            # Initialize index of min deadline job
            # i
            min_task = -1
            # j
            min_job = -1

            # For each task
            for i in range(min_n, max_n+1):
                # For each job in the task
                for job in jobs[i]:
                    # If job is released by this time, and the job is not already complete
                    if (job["release"] <= t and job["remaining_c"] > 0):
                        # If min vars have been populated with indexces (min found so far)
                        if (min_task != -1):
                            # Select this job as min if it has an earlier deadline 
                            if (job["deadline"] < jobs[min_task][min_job]["deadline"]):
                                min_task = i
                                min_job = job["num"]
                        # If no other job is min, select this one
                        else: 
                            min_task = i
                            min_job = job["num"]


            # No jobs ready to be executed
            if min_task == -1:
                next_job = None
            # Execute next job
            else:
                next_job = jobs[min_task][min_job]
                job_c = next_job["c"]

                # Decrement remaining c in job
                jobs[next_job["task"]][next_job["num"]]["remaining_c"] = 0

                # Add execution to out data
                out_data = addExecution(out_data, next_job["task"], next_job["num"], t, t+job_c)

                # Skip to the end of the execution
                c_remaining = job_c-1
    
    # Save data as json
    with open(sys.argv[2], 'w') as out_file:  
        json.dump(out_data, out_file)

main()