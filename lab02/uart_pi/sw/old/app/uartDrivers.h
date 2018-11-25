
/**
 * Return the next value to be read in the UART reading buffer
 */
int read(char * values, int numberMaxToRead);


/**
 * Return the next value to be read in the UART reading buffer
 */
void write(char* toWrite, int numberOfCharacters);
int writeString(char* toWrite);


/**
 * Return the UART connection state
 */
int canRead();


/**
 * Setup of the UART connection
 */
int setup(int wordLength, int rate, int parity);

