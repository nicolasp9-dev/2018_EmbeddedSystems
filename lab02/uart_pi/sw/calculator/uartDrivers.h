
/**
 * Return the next value to be read in the UART reading buffer
 */
int readUart(char * values, int numberMaxToRead);


/**
 * Return the next value to be read in the UART reading buffer
 */
void writeUart(char* toWrite, int numberOfCharacters);
int writeString(char* toWrite);


/**
 * Return the UART connection state
 */
int canRead();


/**
 * Setup of the UART connection
 */
int setupUart(int wordLength, int rate, int parity);

