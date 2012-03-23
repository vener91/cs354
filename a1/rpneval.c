/* Assignment 1
 * by Ter Chrng Ng
 *
 * This is a RPN(Reversed polish notation) evaluator
 */

#include <stdio.h>
#include <stdlib.h>

#define ARRAYSIZE 7
#define STACKSIZE 8

/* readInts reads argv and argc and puts the integers in the stack
 * returns number of ints
 * returns -1 when maxInts is exceeded or reach a unknown charcter
 * Parameters:
 *  stack[]: A empty stack
 *  maxInts: Maximum number of ints allowed
 *  argv[]: Array from input
 *  argc[]: Size of argv
 */
int readInts(int stack[], int maxInts, char *argv[], int argc) {
        int i;
        int k = 0;
        for(i = 1; i < argc; i ++){
                //For each argument
                int tmp = atoi(argv[i]);
                if(tmp > 0){ //check if numeric, put in stack and not negative
                        if(k < maxInts){
                                stack[k] = tmp;
                                k++;
                        }else{
                                //Error due to too much numerical values
                                return maxInts+1;
                        }
                } else {
                        if(tmp < 0){
                                return -1;                      
                        }
                        //Reach half of the input, operators should follow, job done, returning
                        return k;
                }
        }
        return k;
}


/* readOperators reads the input array and examines for operators, operators[] is filled with it
 * returns the number of operators
 * returns -1 when there are too many operators
 * Parameters:
 *  operators[]: A empty array
 *  expectedNumOperators: Expected Number of Operators
 *  argv[]: Array from input
 *  argc[]: Size of argv
 *  indexArgvOperator: The index where it should start reading the operators
 */
int readOperators(char operators[], int expectedNumOperators, char *argv[], int argc, int indexArgvOperator) {
        int i; 
        int k = 0;
        for(i = indexArgvOperator; i < argc; i ++){
                //For each argument
                int tmp = atoi(argv[i]); 
                if(tmp == 0 && argv[i][1] == '\0' && ( argv[i][0] == 'a' || argv[i][0] == 's' || argv[i][0] == 'm' || argv[i][0] == 'd')){ //check if NOT numeric and single char, put in array
                        if(k < expectedNumOperators){
                                operators[k] = argv[i][0];
                                k++;
                        }else{
                                //Error due to too many operators
                                return -3;
                        }
                } else {
                        //Found a numeric after the operators/inbetween operators, return as error
                        return -2;
                }
        }
        return k;
}


/* evaluate the stack of integers and operators
 * return the evaluated result
 * Parameters:
 *  stack[]: A an array filled with integers
 *  operators[]: A array filled with operators
 *  numItemsInStack: Size of stack[]
 */
int evaluate(int stack[], char operators[], int numItemsInStack) {
        
        int i;
        char tmp;
        int result = stack[numItemsInStack-1]; //Get the first value in the result
        for(i = numItemsInStack-2; i >= 0 ; i--){ //Loop through it
                tmp = operators[numItemsInStack - i - 2]; //Math that let it reads the first item of the operator, and the last item of the stack  
                switch( tmp ) {
                        case 'a':
                                result += stack[i];
                                break;
                        case 's':
                                result = stack[i] - result;
                                break;
                        case 'm':
                                result = stack[i] * result;
                                break;
                        case 'd':
                                result = stack[i] / result;
                                break;
                }
        }
        return result;
}


/* Prints "Result is #"
 * Parameters:
 *  intToPrint[]: integer to print
 */
void printInt(int intToPrint) {
        // Just print integer
        printf("Result is %d\n", intToPrint);
}

int main(int argc, char *argv[]){
        
        //Main variables, once set, do not change
        int integerStack[STACKSIZE];
        char operatorArray[ARRAYSIZE];
        
        int result, tmpResult, tmpResult2; 
        int i;

        tmpResult = readInts(integerStack, STACKSIZE, argv, argc);
        if(tmpResult < 0){
                //Error due to too many integers or bad input
                printf("Bad input character encountered.  Quitting.\n");
                return 0; 
        }
        
        if(tmpResult > STACKSIZE || tmpResult == 0){
                printf("Minimum of 1 integer needed. Maximum of 8 integers accepted. Quitting.\n");
                return 0;      
        }

        if(argc != tmpResult * 2){
                printf("Mismatch in numbers of integers and operators. Quitting.\n");
                return 0;
        }

        tmpResult2 = readOperators(operatorArray, tmpResult, argv, argc, tmpResult+1);        
        if(tmpResult2 < 0){
                //Error due to too many integers or bad input
                printf("Bad input character encountered.  Quitting.\n");
                return 0;
        }
                
        printInt(evaluate(integerStack, operatorArray, tmpResult));
        
        return 0;
}


