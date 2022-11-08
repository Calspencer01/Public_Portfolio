
/* A collection of utility I/O functions for flushing the input buffer, pretty
   printing a bitboard and reading/writing bytes from/to a binary file.

   Author: RR
 */
#include "io.h"


/* Flushes stdin by consuming pending characters in the buffer.

   Parameters: N/A
   Returns: N/A
*/
void flushInputBuffer() {
  char c;
  while (((c = getchar()) != '\n') && (c != EOF)) {}
}


/* Prints a single byte extracted from a bitboard.

   This is a private function and should not be called directly. Use prettyPrint
   defined below instead.

   Parameters:
      byte - the byte to be printed.

   Returns: N/A
 */
void _printByte(unsigned short byte) {
    unsigned short mask = 0x80;
    while (mask > 0) {
        char symbol = (byte & mask) ? 'P' : '.';
        printf("%c ", symbol);
        mask >>= 1;
    }
}


/* Prints a bitboard in a human-friendly format.

   The output is formatted as an 8x8 array, with the character 'P' indicating
   squares that are occupied by a piece, and the character '.' indicating
   unoccupied squares.

   Parameters:
      bitboard - the bitboard to be pretty printed.

   Returns: N/A
 */
void prettyPrint(unsigned long bitboard) {
    for (int i = 7; i >= 0; i--) {
        _printByte((unsigned short)((bitboard >> (i * 8)) & 0xff));
        printf("\n");
    }
}


/* Reads the next byte in the input file and returns it. If the file
   cannot be read, then an error message is displayed and the program
   exits.

   Parameters:
      inputFile - a FILE* that points to an already open file.

   Returns:
      The read in byte as an unsigned char.
*/
unsigned char readByte(FILE* inputFile) {
  if (!inputFile) {
    printf("Error! Specified file is not not readable!\n");
    exit(-1);
  }

  unsigned char byte;
  fread(&byte, sizeof(unsigned char), 1, inputFile);
  return byte;
}


/* Writes the supplied byte to the output file.

   Parameters:
      outputFile - a FILE* that points to an already open file.
      byte - the byte to be written to the open file.

   Returns:
      N/A
*/
void writeByte(FILE* outputFile, unsigned char byte) {
  if (!outputFile) {
    printf("Error! Specified file is not writable!\n");
    exit(-1);
  }

  fwrite(&byte, sizeof(unsigned char), 1, outputFile);
}
