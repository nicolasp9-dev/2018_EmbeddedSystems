#include "msp.h"

/**
 * Return the GPIO basic address to access and setup a GPIO
 *
 * @param registerNumber    The GPIO register number
 * @param portNumber        The GPIO port bit on the register
 *
 * @return The 64 bits adress of the GPIO
 */
DIO_PORT_Odd_Interruptable_Type * getPortBaseAddress(int registerNumber){
    int shift = (registerNumber-1)%2;
    int jump = (registerNumber-1)/2;
    return (DIO_PORT_Odd_Interruptable_Type *) (DIO_BASE + jump * 0x0020 + shift * 0x0001);
}


/**
 * Check if gpio register number and port number are valid to be use as parameters for GPIO access
 *
 * @param registerNumber    The GPIO register number
 * @param portNumber        The GPIO port bit on the register
 *
 * @return True if it's a valid port, false if it's not
 */
int checkValidGpio(int registerNumber, int portNumber){
    if((registerNumber < 1) || (registerNumber > 6)) return 0;
    if((portNumber < 0) || (portNumber > 7)) return 0;
    return 1;
}

/**
 * @ref Manipulation 1
 * WARNING: Unlimited loop - Function never returns if GPIO is valid
 * Generates a PWM signal of a certain number of ticks high and ticks low
 *
 * @param registerNumber    The pwm output register number (GPIO)
 * @param portNumber        The pwm output port bit on the register (GPIO)
 * @param ticksHigh         The number of ticks for the high level output signal
 * @param ticksLow          The number of ticks for the low level output signal
 */
void pwmGeneratorBlocking(int registerNumber, int portNumber, int ticksHigh, int ticksLow){
    if(!checkValidGpio(registerNumber, portNumber)){
        return;
    }

    DIO_PORT_Odd_Interruptable_Type * portBaseAddress = getPortBaseAddress(registerNumber);

    portBaseAddress->DIR = (1 << portNumber);

    int i;

    while(1){
	    portBaseAddress->OUT = (1 << portNumber);
        for(i=0;i<ticksHigh;i++);
        portBaseAddress->OUT = (0 << portNumber);
        for(i=0;i<ticksLow;i++);
	}
}

/**
 * Check the number passed by reference and change it to the lowest boundary if it reached the highest
 * one or to the highest one if it reached the lowest.
 *
 * @param number   A reference to the number to check and edit if necessary
 */
void checkForRotationalBundaries(int *number){
    if(*number < 0){*number = 7;}
    else if(*number > 7){*number = 0;}
}

/**
 * @ref Manipulation 2
 * WARNING: Unlimited loop - Function never returns if GPIO register is valid
 *
 * @param registerNumber   The GPIO register where to apply the "chenillard effect"
 * @param speedTicks       The number of ticks to wait with the before switching output
 */
void chenillardEffect(int registerNumber, int speedTicks){
    if(!checkValidGpio(registerNumber, 0)){
        return;
    }

    DIO_PORT_Odd_Interruptable_Type * portBaseAddress = getPortBaseAddress(registerNumber);

    portBaseAddress->DIR = 0xFF;
    portBaseAddress->OUT = 0x00;

    int lastLed = 0;
    int nextLed = 1;
    int k;

    while(1){
        portBaseAddress->OUT = (0 << lastLed);
        portBaseAddress->OUT = (1 << nextLed);
        lastLed++;
        nextLed++;
        checkForRotationalBundaries(&lastLed);
        checkForRotationalBundaries(&nextLed);
        for(k=0;k<speedTicks;k++);
	}
}

DIO_PORT_Odd_Interruptable_Type * portBaseAddress = 0;
int globalPortNumber;

DIO_PORT_Odd_Interruptable_Type * portBaseAddress2 = 0;
int globalPortNumber2;

/**
 * Setup a GPIO to be use with the function toggle Gpio
 *
 * @param registerNumber    The GPIO register number
 * @param portNumber        The GPIO port bit on the register
 */
void setupGpio(int registerNumber, int portNumber){
    if(!checkValidGpio(registerNumber, portNumber)){return;}
    portBaseAddress = getPortBaseAddress(registerNumber);
    portBaseAddress->DIR |= (1 << portNumber);
    globalPortNumber = portNumber;
}

void setupGpio2(int registerNumber, int portNumber){
    if(!checkValidGpio(registerNumber, portNumber)){return;}
    portBaseAddress2 = getPortBaseAddress(registerNumber);
    portBaseAddress2->DIR |= (1 << portNumber);
    globalPortNumber2 = portNumber;
}

/**
 * Toggle the previously set GPIO - Return if not set
 */
void toggleGpio(){
    if(!portBaseAddress){return;}
    static int state = 0;
    if(state) portBaseAddress->OUT |= (1 << globalPortNumber);
    else portBaseAddress->OUT &= ~(1 << globalPortNumber);
    state = !state;
}

void toggleGpio2(){
    if(!portBaseAddress2){return;}
    static int state = 0;
    if(state) portBaseAddress2->OUT |= (1 << globalPortNumber2);
    else portBaseAddress2->OUT &= ~(1 << globalPortNumber2);
    state = !state;
}


#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))
#define MAX_TICKS 65535

/**
 * Setup the clock with predefined parameters
 */
void setupClock(){
    // Authorize the clock parameters changes
    CS->KEY = CS_KEY_VAL;
    // Put the 32768-Hz oscillator as Auxiliary clock
    CS->CTL1 = CS_CTL1_SELA__LFXTCLK;
}

/**
 * Setup the A0 timer with predefined parameters
 */
void setupAndRunTimerA0(){
     TIMER_A0->CTL = TIMER_A_CTL_SSEL__ACLK + TIMER_A_CTL_ID__8 + TIMER_A_CTL_MC_1 + TIMER_A_CTL_CLR + TIMER_A_CTL_IE;
     TIMER_A0->CCTL[0] |= TIMER_A_CCTLN_CCIE;
}

void setupAndRunTimerA2(int time){
     TIMER_A2->CCR[0] = 32*time;
     TIMER_A2->CCTL[1]= TIMER_A_CCTLN_OUTMOD_7;
     TIMER_A2->CCTL[2]= TIMER_A_CCTLN_OUTMOD_7;
     TIMER_A2->CTL = TIMER_A_CTL_SSEL__ACLK + TIMER_A_CTL_MC_1 + TIMER_A_CTL_ID__1 + TIMER_A_CTL_CLR;
}



int numberOfCompleteCycles = 0;
int remainingTicks = 0;

/**
 * Set the delay for A0 timer
 *
 * @time The delay time in ms
 */
void setDelayMs(int time){
    int ticksToDo = 4*time;
    numberOfCompleteCycles = ticksToDo / MAX_TICKS;
    remainingTicks = ticksToDo % MAX_TICKS;
}

/**
 * Set the delay for A0 timer
 *
 * @time The delay time in us
 */
void setDelayUs(int time){
    int ticksToDo = time/240;
    numberOfCompleteCycles = ticksToDo / MAX_TICKS;
    remainingTicks = ticksToDo % MAX_TICKS;
}

/**
 * Returns true if some time is reaming on the timer complete time
 *
 * @return True if some time is reaming, false if not
 */
int isTimeReaming(){
    if(numberOfCompleteCycles || remainingTicks) {
        return 1;
    }
    return 0;
}

/**
 * Update the timer register with the reaming time
 */
void updateReamingTime(){
    if(numberOfCompleteCycles > 0){
        TIMER_A0->CCR[0] = MAX_TICKS;
        numberOfCompleteCycles--;
    }
    else if(remainingTicks > 0){
        TIMER_A0->CCR[0] = remainingTicks;
        remainingTicks = 0;
    }
}

/**
 * Delay that blocks the current thread but uses a timer as feedbacj
 */
void delayBlocking(){
    while(1){
        if(!isTimeReaming()) return;
        updateReamingTime();
        while(!CHECK_BIT(TIMER_A0->CCTL[0], TIMER_A_CCTLN_CCIFG_OFS));
        TIMER_A0->CCTL[0] &= ~(1 << TIMER_A_CCTLN_CCIFG_OFS);
    }
}


/**
 * Test of the blocking delay using a timer as feedback
 */
void delayWithTimer(){
    setupClock();
    setupAndRunTimerA0();
    setupGpio(4,0);
    while(1){
        toggleGpio();
        setDelayMs(25);
        delayBlocking();
        toggleGpio();
        setDelayMs(500);
        delayBlocking();
    }
}

#define PWM_PERIOD_US 20000

/**
 * Pwm with a blocking timer
 *
 * @percent the percent of time where to be in high lever (between 0 and 100)
 */
void pwmWithTimerBlocking(int percent){
    if((percent < 0) || (percent > 100)) return;
    setupGpio(4,0);
    setupAndRunTimerA0();
    int tHigh = PWM_PERIOD_US*percent/100;
    int tLow = (PWM_PERIOD_US*(100-percent)/100);
    while(1){
        toggleGpio();
        setDelayUs(tHigh);
        delayBlocking();
        toggleGpio();
        setDelayUs(tLow);
        delayBlocking();
    }
}

#define INTERRUPT_TIME_MS   50

/**
 * Catch the TA0 interrup feedback and launch ADC conversion
 */
void TA0_0_IRQHandler(void)
{
    if(!isTimeReaming()){
        ADC14->CTL0 |= ADC14_CTL0_SC | ADC14_CTL0_ENC;
        toggleGpio();
        setDelayMs(INTERRUPT_TIME_MS);
    }
    updateReamingTime();
    TIMER_A0->CCTL[0] &= ~(1 << TIMER_A_CCTLN_CCIFG_OFS);
}

/**
 * Setup a timer to do a periodic interrupt
 */
void periodicInterrupt(){
    setupClock();
    NVIC_EnableIRQ(TA0_0_IRQn);
    setDelayMs(INTERRUPT_TIME_MS);
    updateReamingTime();
    setupAndRunTimerA0();
}

int read_x;
int read_y;

/**
 * Catch the ADC interrup feedback and write data to the PWM timers
 */
void ADC14_IRQHandler(void) {
    TIMER_A2->CCR[1] = changeCoordinates(ADC14->MEM[0]);
    TIMER_A2->CCR[2] = changeCoordinates(ADC14->MEM[1]);
    toggleGpio2();

}

/**
 * Setup the adc to get values from two GPIO ports
 */
void setupAdc(){
    P4->SEL0 |= (1<<0); // mode 1 for port 4, reg0
    P4->SEL0 |= (1<<2);
    ADC14->CTL0 = ADC14_CTL0_SHT0__16 | ADC14_CTL0_SHP | ADC14_CTL0_ON | ADC14_CTL0_CONSEQ_1;
    ADC14->CTL1 = ADC14_CTL1_RES_2;
    ADC14->MCTL[0] |= ADC14_MCTLN_INCH_13;
    ADC14->MCTL[1] |= ADC14_MCTLN_INCH_11 | ADC14_MCTLN_EOS;
    ADC14->IER0 |= ADC14_IER0_IE0;
}

/**
* Changes the coordinates from ADC domain to A2 timer domain
*/
int changeCoordinates(int x)
{
  return (x) * (64-32) / 4096 + 32;
}

/**
 * Setup the interruptions for ADC and A0
 */
void setupInterruptions(){
    NVIC_EnableIRQ(TA0_0_IRQn);
    NVIC_EnableIRQ(ADC14_IRQn);
    NVIC_SetPriority(TA0_0_IRQn,1);
    NVIC_SetPriority(ADC14_IRQn,2);
}

/**
 * Setup timer outputs for hardware PWM
 */
void setupTimerOutputs(){
    P5->OUT = (1<<6) + (1<<7);
    P5->DIR |= (1<<6) + (1<<7);
    P5->SEL0 |= (1<<6) + (1<<7);
}

#define PWM_FREQUENCY   20

/**
 * Main function, exectute last TP manipulation
 */
void main(void)
{
	WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;		// stop watchdog timer

    setupClock();
    setupInterruptions();
    setupTimerOutputs();

    setupGpio(2,6);
    setupGpio2(2,5);

    setDelayMs(INTERRUPT_TIME_MS);
    updateReamingTime();
    setupAndRunTimerA0();

    setupAndRunTimerA2(PWM_FREQUENCY);

    setupAdc();

    while (1);

}
