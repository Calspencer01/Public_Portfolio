# Author: Calvin Spencer

# Imports
import sys
import json
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Arrow, Circle
from matplotlib.pyplot import figure
import math

# Constants
arrow_offset = .25
arrow_length = .1
rect_offset = .15
rect_height = .05
colors = ["#fdb462", "#80b1d3", "#fb8072", "#8dd3c7", "#bebada", "#a89f91"]
    # Color brewer: https://colorbrewer2.org/#type=qualitative&scheme=Accent&n=6


# Draw an up arrow at coordinate parameters
def drawUpArrow(x, y):
    plt.arrow(x, .05 + y + arrow_offset, 0, arrow_length, width = .05, head_width = .5, head_length = .098)
    
# Draw a down arrow at coordinate parameters
def drawDownArrow(x, y):
    plt.arrow(x, y + arrow_offset + (2*arrow_length), 0, -1*arrow_length, width = .05, head_width = .5, head_length = .098)

# Returns the height of an axis given a task number 
def task_y(task_num):
    multiplier = 1;
    return (task_num * multiplier);

# Custom x axis for each task
# task_num: int task number
# max_t: maximum value on x scale
# interval: modulo value for larger ticks and tick labels (5 = every fifth tick will be larger and have a label)
def drawCustomAxis(task_num, max_t, interval):
    y = task_y(task_num)
    ticks = list(range(0, max_t))
    sml_ticks_y = [y - .05, y + .05]
    lrg_ticks_y = [y - .1, y + .1]
    label_offset = -.15
    
    # Horizontal line
    plt.plot([0, max_t], [y, y], color = "black")
    
    # Tick marks + labels
    for tick_x in ticks:
        # Label task
        plt.text(-5, y, ("Task: " + str(task_num)), ha = "right", color = colors[task_num])
        if (tick_x % interval == 0):
            # Larger ticks + labels at specified interval
            plt.text(tick_x, y + label_offset, str(tick_x), ha = "center", size = "x-small")
            plt.plot([tick_x, tick_x], lrg_ticks_y, color = "black", linewidth = 0.02)
        else:
            # Regular tick
            plt.plot([tick_x, tick_x], sml_ticks_y, color = "black", linewidth = 0.02)

# Add a rectangle indicating the time of execution
# Execution: execution object containing a taskNum, start, and end
# Axis: axis object for plt
def drawExecutionRect(execution, axis):
    task_num = execution['taskNum']
    start = execution["start"]
    end = execution["end"]
    rect = Rectangle((start,task_y(task_num) + rect_offset), (end - start), rect_height, color = colors[task_num])
    axis.add_patch(rect)
    
    
def drawTaskJobs(task, max_t, axis):
    release = task["phase"]
    c = task["c"]
    deadline = task["deadline"]
    period = task["period"]
    num = task["num"]
    
    jobs = range(math.ceil(max_t / period))
    
    for job in jobs:
        job_release = (period * job) + release
        job_deadline = job_release + deadline
        if (job_release <= max_t):
            drawUpArrow(job_release, task_y(num))
        else:
            break
            
        if (job_deadline <= max_t):
            drawDownArrow(job_deadline, task_y(num))
        else:
            break
        
    
# Main
def main():
    # Data intake
    if len(sys.argv) < 3:
        print("Missing argument.")
        print("Usage: testing.py <JSON file> <Output pdf>")
        sys.exit(1)
    json_file = sys.argv[1]
    output_file = sys.argv[2]
    
    with open(json_file) as json_data:
        input_data = json.load(json_data)

    tasks = input_data['tasks']
    max_t = input_data['max_t']
    executions = input_data['executions']
    
    # Find number of tasks and executions
    tasks_n = len(tasks)
    executions_n = len(executions)
    
    # Prepare figure for custom axes
    ax = plt.axes()
    ax.autoscale_view()
    plt.axis('off')
    

    # Add axes and arrows for release times + deadlines, per task
    for i, task in enumerate(tasks):
        drawCustomAxis(i, max_t + 1, 5)
        drawTaskJobs(task, max_t, ax)
        
     # Add rectangles for each execution
    for i, execution in enumerate(executions):
        drawExecutionRect(execution, ax)
    
    
    #plt.savefig('Schedule1.pdf', bbox_inches='tight')
    plt.savefig(output_file, bbox_inches='tight')
main()
