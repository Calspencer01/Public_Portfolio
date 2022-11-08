
/* stats.c.

   Authors: Calvin Spencer & Jack Dowell
*/

#include "io.h"
#include <stdio.h>

/* computeStats: prompts the user for integer inputs and returns the mean and variance of the inputs.

    Parameters:
        None, all values are input by the user
    Returns:
        None, mean and variance are automatically printed.
*/
void computeStats(){
 int num = 1;
    int sum = 0;
    int numImputs = 0;
    int inputs[] = {};
    float average = 0.00;
    float variance = 0.00;

    // Loop for inputting numbers; loops until broken when input = -1.
    while (1){
        printf("Please enter a number: ");
        int numRead = scanf("%i", &num);
        
        if (num == -1){
            break;
        }
        else if (numRead == 0){
            printf("Sorry, that is not a valid number - input ignored.");
        }
        else{
            inputs[numImputs] = num;
            numImputs = numImputs + 1;
            sum = sum + num;
        }
        flushInputBuffer();
    }

    // Compute average and variance if 1 or more number was input
    if (numImputs > 0){
        average = sum/numImputs;
        int sumSq = 0;
        for (int i = 0; i < numImputs; i++){
            sumSq = sumSq + (inputs[i] * inputs[i]);
        }
        variance = (sumSq / numImputs) - (average * average);
    }
    
    printf("Mean: %.2f, Variance: %.2f", average, variance);
}

/* main: Main method, calls computeStats
    No parameters, returns an integer
*/
int main(){
   computeStats();

    return 0;
}

