/* Authors: Calvin Spencer & Henry Howell 
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

void checkArgs(int numArgs) {
    if (numArgs != 3){
        printf("# ERROR! User forgot to provide *two* arguments when running the program\n");
        printf("./life glider.txt\n");
        printf("Usage: ./life <filename> <verbosity>\n");
        printf("    where <filename> = name of the configuration file.\n");
        printf("          <verbosity> = 0 (no output), 1 (minimal output), or 2 (animated output)\n");
        exit(-1);
    }
}
/* checkFilename: Exits program if filename is invalid
* @param fp: pointer to file
*/
void checkFilename(FILE* fp){
    if (fp == NULL) {
        printf("Error! Cannot find given file\n");
        exit(-1);
    }
}

/* checkVerbosity: Returns the verbosity if valid, exits program if invalid
* @param args: Verbosity; Third command line argument
* @returns verbosity
*/
int checkVerbosity(int verbosity) {
    //Check if verbosity is in bounds
    if (!(verbosity <= 2 && verbosity >= 0)){
        printf("Error! Invalid verbosity\n");
        exit(-1);
    }

    return verbosity;
}

/* checkFilename: Exits program if array's memory allocation failed
* @param arr: pointer to array
*/
void checkAlloc(int* arr){
    //Check if malloc returned NULL indicating a memory allocation failure
    if (arr == NULL){
        printf("Error! Failed to allocate memory");
        exit(-3);
    }
}

/* checkFilename: Exits program if scan found no match
* @param x: number of matches returned from scan call
* @param str: output if invalid
*/
void checkScan(int x, char str[]) {
    if (x == 0) {
        printf("%s\n", str);
        exit(-2);
    }
}

/* checkDimensions: Exits program if scan missed a match in the dimensions
* @param x: number of matches returned from scan call (should be 2 if valid)
*/
void checkDimensions(int x) {
    if (x < 2){
            printf("Error. Invalid cell dimension(s).\n");
            exit(-1);
    }
}

/* initArr: Populates the given 2-dimensional array with 0s
* @param arr: pointer to 2D array to initialize
* @param r: number of rows in 2D array
* @param c: number of columns in 2D array
*/
void initArr(int *arr, int r, int c) {
  int i, j;
  for (i = 0; i < r; i++) {
    for (j = 0; j < c; j++) {
	    arr[(i * c) + j] = 0;
    }
  }
}

/* findIndex: Returns index in array given row and column
* @param row: Row number of index
* @param col: Column number of index
* @param c: number of columns in 2D array
* @returns array index calculated using row number, column number, and number of columns
*/
int findIndex(int row, int col, int c){
    return (row * c) + col;
}

/* north: Returns index of cell directly above
* @param origin: Index to travel from
* @param r: number of rows in 2D array
* @param c: number of columns in 2D array
* @returns index of cell one row above
*/
int north(int origin, int r, int c){
    //If on northernmost row 
    if (origin < r){
        //Wrap to south
        return origin + ((c - 1) * r);
    }
    else{
        //Move one row north
        return origin - c;
    }
}

/* south: Returns index of cell directly below
* @param origin: Index to travel from
* @param r: number of rows in 2D array
* @param c: number of columns in 2D array
* @returns index of cell one row below
*/
int south(int origin, int r, int c){
    //If on southernmost row
    if (origin > (c - 1) * r){
        //Wrap to north
        return origin - ((c - 1) * r) ;
    }
    else{
        //Move one row south
        return origin + c;
    }
}

/* west: Returns index of cell directly to the left
* @param origin: Index to travel from
* @param c: number of columns in 2D array
* @returns index of cell one column left
*/
int west(int origin, int c){
    //if in westernmost column
    if ((origin % c) == 0){
        //Wrap to east
        return origin + (c - 1);
    }
    else {
        //Move one column west
        return origin - 1;
    }
}

/* west: Returns index of cell directly to the right
* @param origin: Index to travel from
* @param c: number of columns in 2D array
* @returns index of cell one column right
*/
int east(int origin, int c){
    //If in easternmost column
    if ((origin % c) == c - 1){
        //Wrap to west
        return origin - (c - 1);
    }
    else {
        //Move one column east
        return origin + 1;
    }
}

/* printArr: Prints 2D array to terminal, with 1s as @ and 0s as -
* @param arr: pointer to 2D array to print
* @param r: number of rows in 2D array
* @param c: number of columns in 2D array
*/
void printArr(int *arr, int r, int c){
    for (int i = 0; i < r; i++){
        for (int j = 0; j < c; j++){
            if (arr[findIndex(i, j, c)] == 0){
                printf("-");
            }
            else {
                printf("@");
            }
        }
        printf("\n");
    }
}

/* getNeighborCount: Counts the number of neighbors of a given cell
* @param arr: pointer to 2D array
* @param origin: index of given cell
* @param r: number of rows in 2D array
* @param c: number of columns in 2D array
* @return the count of the number of neighbors
*/
int getNeighborCount(int *arr, int origin, int r, int c){
    int count = 0;

    //Sum up the number of neighbors in all 8 spots relative to the middle cell
    count = count + arr[north(east(origin, c), r, c)];
    count = count + arr[north(origin, r, c)];
    count = count + arr[north(west(origin, c), r, c)];
    count = count + arr[west(origin, c)];
    count = count + arr[south(west(origin, c), r, c)];
    count = count + arr[south(origin, r, c)];
    count = count + arr[south(east(origin, c), r, c)];
    count = count + arr[east(origin, c)];

    return count;
}

/* copy: Copies the first 2D array (arr1) into the second (arr2)
* @param arr1: pointer to first 2D array (the original)
* @param arr2: pointer to second 2D array (the new copy)
* @param r: number of rows in both 2D arrays
* @param c: number of columns in both 2D arrays
*/
void copy(int *arr1, int *arr2, int r, int c) {
    for (int i = 0; i < r; i++){
        for (int j = 0; j < c; j++){
                arr2[findIndex(i, j, c)] = arr1[findIndex(i, j, c)];
        }
    }
}

/* iterate: Carries out the rules of Conway's Game of Life on each cell on the grid
* @param arr: pointer to 2D array (the grid)
* @param r: number of rows in 2D array
* @param c: number of columns in 2D array
*/
void iterate(int *arr1, int r, int c){
    //Generate new blank 2D array to store changes until iteration is complete
    int *arr2 = (int *)malloc(sizeof(int) * r * c);

    //Determine fate of all cells on grid
    for (int i = 0; i < r; i++){
        for (int j = 0; j < c; j++){
            int index = findIndex(i, j, c);
            //Find number of neighbors around this cell
            int neighbors = getNeighborCount(arr1, index, r, c);
        
            // If cell == 1 (if cell is alive)
            if (arr1[index]){ 
                // Cell is alive, stays alive if it has 2 or 3 neighbors
                arr2[index] = (2 <= neighbors && neighbors <= 3);   
            }
            else {
                //Cell is dead, becomes alive if it has 3 neighbors
                arr2[index] = (neighbors == 3);
            }
        }
    }

    //Copy new array into the ongoing array
    copy(arr2, arr1, r, c);
}

/* Main method
*  Reads input file & initializes the grid before iterating the game the paramaterized number of times
* @param: numArgs: the number of command-line arguments
* @param: args: pointer to array of command-line arguments
* returns 0
*/
int main(int numArgs, char *args[]) {
        // ---- Command Line Inputs (Verbosity, Filename) ----

    //Check for correct number of command line arguments
    checkArgs(numArgs);

    //Convert third argument to integer, check if within correct bounds for verbosity
    int verbosity = checkVerbosity(atoi(args[2]));

    //Allocate space for filename string
    char filename[100];

    //Store filename from cmd-line
    strcpy(filename, args[1]);

    //Attempt to open file
    FILE* fp = fopen(filename, "r");

    //Check if filename is valid
    checkFilename(fp);


        // ---- Config File Inputs ----
        
    int i;
    int *arr;
    
    //Scan dimensions of grid, exit program if not found
    int r = -1;
    checkScan(fscanf(fp, "%d", &r), "Error. Invalid number of rows");
    int c = -1;
    checkScan(fscanf(fp, "%d", &c), "Error. Invalid number of columns");
    

    //Allocate memory for 2D array
    arr = (int *)malloc(sizeof(int) * r * c); 

    //Check if allocation succeeded
    checkAlloc(arr);

    //Initialize array to all 0s
    initArr(arr, r, c);

    //Scan iterations
    int iterations = -1;
    checkScan(fscanf(fp, "%d", &iterations), "Error. Invalid number of iterations");

    //Scan number of initial live cells
    int startSize = -1;
    checkScan(fscanf(fp, "%d", &startSize), "Error. Invalid start size");

    //For each live cell
    for (int l = 0; l < startSize; l++){
        //Scan live cell coordinate
        int r1 = 0, c1 = 0;
        checkDimensions(fscanf(fp, "%d %d", &r1, &c1));

        //Set live cell to 1
        arr[findIndex(r1, c1, c)] = 1;
    }

    //Close file reader
    fclose(fp);

        // ---- Run the game ----

    //Iterate the supplied number of times
    for (int i = 0; i < iterations; i++){
        //Dont print for every iteration if verbosity is 1
        if (verbosity > 1){
            system("clear");
            printArr(arr, r, c);
            usleep(200000);
        }

        iterate(arr, r, c);
    }

    //Print final output if verbosity is 2 or 1
    if (verbosity > 0){
        usleep(200000);
        printArr(arr, r, c);
    }
    
    return 0;
}