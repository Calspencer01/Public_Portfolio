
#ifndef IO_H
#define IO_H

#include <stdio.h>
#include <stdlib.h>

void flushInputBuffer();
void prettyPrint(unsigned long);
unsigned char readByte(FILE*);
void writeByte(FILE*, unsigned char);

#endif
