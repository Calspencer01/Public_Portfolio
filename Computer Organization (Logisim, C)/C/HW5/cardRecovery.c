
/* cardRecovery.c

   Authors: Calvin Spencer & Jack Dowell
*/
#include <stdio.h>
#include "io.h"

/*


*/
int recoveredFiles(){
    FILE* fp;
    fp = fopen("card.raw", "r");

    if (fp == NULL) {
        printf("Can't open input file in.list!\n");
        exit(1);
    }
    
    unsigned char bytes;
    unsigned char* pBytes = *bytes;

    do {
        addByte(readByte(pBytes, fp));

        printBytes(pBytes);
        printf("byte: %i\n", nextByte);
        
        if ((nextByte == FF) & (prev1Byte == D8) & (prev2Byte == FF) & (prev3Byte == E1 | prev3Byte == E0)){
            printf("NEW PICTURE\n");
        }

        
        if (nextByte == 217){
            break;
        }
    } while (1);
    

    fclose(fp);
    return 0;
}

/*

*/
void addByte(unsigned char* arr, unsigned char byte) {
    arr[3] = arr[2];
    arr[2] = arr[1];
    arr[1] = arr[0];
    arr[0] = byte;
}

void printBytes(unsigned char* arr) {
    for (int i = 0; i < sizeof(arr); i++){
        printf("%i, " arr[i]);
    }
}

/*


*/
int main(){
    recoveredFiles();
    return 0;
}