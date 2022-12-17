/*  HW 7: Implementation of C's string library
    Authors: Calvin Spencer & Henry Howell
*/  

#include "strings.h"
#include <stdlib.h>

#define nulChar '\0'

/* Appends a copy of suffix to the end of original, then adds nul char
    Parameters
        original: pointer to original string being manipulated
        suffix:   pointer to string being appended to original
    Returns
        pointer to original 
*/
char* mystrcat(char* original, const char* suffix){
    //Set pointer to end of original string
    char* originalPtr = original + mystrlen(original);

    //Incrementing the pointers to the end of the original string and the suffix, append each char to original
    while (*suffix != nulChar){
        * (originalPtr++) = * (suffix++);
    }

    //Add nul character
    *originalPtr = nulChar;

    return original;
}

/* Finds first occurance of c in string
    Parameters
        string: string being searched within
        c: character being searched for
    Returns pointer to location of c in string
        
*/
char* mystrchr(const char* string, int c){
    int found = 0;

    //Build new mutable string
    char* newString = malloc(mystrlen(string) + 1);
    mystrcpy(newString, string);

    //Loop through entire string
    while(*newString != nulChar) {

        //Break loop if character is found
        if (*newString == c){
            found = 1;
            break;
        }

        //Increment string pointer
        newString++;
    }

    //Return NULL if c was never found in string
    if (found) {
        return newString;
    } 
    else {
        return NULL;
    }
}

/* Compares strings (checks if each character is equal)
    Parameters
        str1: first string being checked against, used during iteration
        str2: second string being compared to
    Returns integer representation of comparison (0 = equal)
        
*/
int mystrcmp(const char* str1, const char* str2){
    int result = 0;

    //Iterate through string 1
    while (*str1 != nulChar){

        //Compare characters in strings
        if (*str1 != *str2){
            //Calculate result (difference)
            result = *str1 - *str2;
            break;
        }

        //Compare next index
        str1++;
        str2++;
    }

    return result;
}

/* Copies string into the given location
    Parameters
        location: 
        string:
    Returns
        pointer to location of copied string
*/
char* mystrcpy(char* location, const char* string){
    //Point to the start of the new string location
	char *ptr = location;

    //Storing old string in new location
	while (*string != nulChar) {
		* (location++) = * (string++);
	}

	//Add nul character
	*location = nulChar;

	return ptr;
}

/*  Takes in a string of characters and returns a duplicate of it.
    Parameters
        string: a string of characters to be duplicated
    Returns an identical string of characters to the one inputted.
*/
char* mystrdup(const char* string){
    char *newString;
    char *ptr;

    //Allocate memory for new string
    newString = malloc(mystrlen(string) + 1);

    //point to start of new String
    ptr = newString;

    //Store in new memory
    while (*string != nulChar){
        * (ptr++) = * (string++);
    }
        
    //End string
    *ptr = nulChar;

    return newString;
}

/*  Runs through a given string to determine its size
    Parameters
       string: the inputted to determine the size of
    Returns the length of the given string with the type size_t
*/
size_t mystrlen(const char* string){
    int length = 0;

    //Loop until nulchar is found
    while (string[length] != nulChar){
        length++;
    }

    return (size_t) length;
}

/* Checks for the first occurrence of string2 within string1
    Parameters 
        string1: the main string to iterate through
        string2: the smaller string to be searched for within string1.
    Returns a pointer to the first occurence of string2 in string1 or if it does not occur, returns NULL.
*/
char* mystrstr(const char* string1, const char* string2){
    //Build new mutable string
    char* newString1 = malloc(mystrlen(string1) + 1);
    mystrcpy(newString1, string1);


    //Iterate through string1
    while (*newString1 != nulChar) {
        //If first characters match, compare entire strings
        if (*newString1 == *string2){
            //if equal, return string1
            if (!mystrcmp(newString1, string2)){
                return newString1;
            }
        }

        //Check next index in string1
        newString1++;
    }

    return NULL;
}