#include "uartDrivers.h"
#include <string.h>
#include <stdio.h>
#include<stdlib.h>
#include "system.h"
#include "io.h"

#define CHAR_SIZE 1000

#define MULT 1
#define ADD 2
#define SUB 3
#define DIVIDE 4

int signValue(char value){
    switch(value){
    case 43 : return ADD;
    case 45 : return SUB;
    case 42 : return MULT;
    case 47 : return DIVIDE;
    default : return 0;
    }
    return 0;
}

int main()
{
	printf("Calculator is running\n");
	char welcome[] = "Welcome to our super calculator !\n";
	writeString(welcome);

	while(1){
		char value[2];
		while(canRead()){
			readUart(value, 1);
		}
	    char welcome[] = "\n------\nPlease enter what you want to compute:\n";
        writeString(welcome);

        int mustStop = 0, i;
		while(!canRead()){
			for(i = 0; i < 10000; i++);
		}

		char input[CHAR_SIZE];
		readUart(input, CHAR_SIZE);


		char received_m[1000] = "Calcul :";
		strcat(received_m, input);
		strcat(received_m, "\n");
		writeString(received_m);

		int numbers[10];
		int signs[9];

		int currentNumber = 0;

		char *ptr = input;
        int wasWrite = 0;
        int position = 0;
		while(*ptr){
			if(*ptr >= '0' && *ptr <= '9'){
			    wasWrite = 1;
				if(position == 0)numbers[currentNumber] = *ptr - '0';
				else numbers[currentNumber] =  *ptr - '0' + 10*numbers[currentNumber];
				position++;
			}
			else if(signValue(*ptr)){
			    if(wasWrite == 0){
			        char error[] = "The calcul isn't correct\n";
			        mustStop = 1;
			        writeString(error);
			        break;
			    }
			    if(currentNumber == 9){
                    char error[] = "Calcul is too long\n";
                    mustStop = 1;
                    writeString(error);
                    break;
                }
                signs[currentNumber] = signValue(*ptr);
                currentNumber++;
                wasWrite = 0;
                position = 0;
			}
			ptr++;
		}

		if(currentNumber == 0){
            char error[] = "Calcul is missing\n";
            mustStop = 1;
            writeString(error);
        }

        int currentEmplacementCalcul = 0;

        int lowPriorityNum[10];
        int lowPrioritySigns[9];

        if(mustStop) continue;
        for(i = 0; i < currentNumber; i++ ){
            if(signs[i] == MULT){numbers[i+1] = numbers[i] * numbers[i+1];}
            else if(signs[i] == DIVIDE){numbers[i+1] = numbers[i] / numbers[i+1];}
            else{
                lowPriorityNum[currentEmplacementCalcul] =  numbers[i];
                lowPrioritySigns[currentEmplacementCalcul] = signs[i];
                currentEmplacementCalcul++;
            }
        }
        lowPriorityNum[currentEmplacementCalcul] = numbers[i];

        for(i = 0; i < currentEmplacementCalcul; i++ ){
            if(lowPrioritySigns[i] == ADD){lowPriorityNum[i+1] = lowPriorityNum[i] + lowPriorityNum[i+1];}
            else if(lowPrioritySigns[i] == SUB){lowPriorityNum[i+1] = lowPriorityNum[i] - lowPriorityNum[i+1];}
        }

        char out[50];
        sprintf(out, "The result is : %d\n", lowPriorityNum[i]);
        printf(out);
        writeString(out);
    }

	return 0;
}

