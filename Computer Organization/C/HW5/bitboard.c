
/* bitboard.c.

   Authors: Calvin Spencer & Jack Dowell
*/

#include "io.h"
/* computePawnMoves:
Parameters:
    - pawnPositions
    - whitePieces
    - blackPieces
Returns: 
    - unsigned long ("bitboard") of all possible pawn moves
*/
unsigned long computePawnMoves(unsigned long pawnPositions, unsigned long whitePieces, unsigned long blackPieces){
    unsigned long doubleForwardRank = 0x00000000FF000000; //1s across rank 4
    unsigned long captures = ((pawnPositions << 9) & blackPieces | (pawnPositions << 7) & blackPieces);
    unsigned long forwards = ((pawnPositions << 8) & ~(blackPieces | whitePieces | pawnPositions));
    unsigned long doubleForwards = ((forwards << 8) & doubleForwardRank);

    return(forwards | captures | doubleForwards);
}

/*

*/
int main(){
        //For testing
    unsigned long pawnPositions=0x0000000400409900;
    unsigned long whitePieces=0x0000000000100000;
    unsigned long blackPieces=0x0000000000280000;
    
    computePawnMoves(pawnPositions, whitePieces, blackPieces);

    return 0;
}