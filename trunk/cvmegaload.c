/*****************************************************
Project :   CVMegaload
Version :   1.00
Date    : 14/05/2004
Author  : Ralph Hilton                    
Chip type           : ATmega
Program type        : Bootloader
Clock frequency     : 7.372800 MHz
Data Stack size     : 256
Acknowledgement  : Modified from original code by Sylvain Bissonnette
*****************************************************/
/*****************************************************
Note: BAUDRATE must be correctly defined below
Supported values are
9600 19200 38400 57600 115200
Chip header is included by cvmegaload.h from the project configuration
// The project should be compiled with the following compiler options:       
// Promote char to int
// Char is unsigned
// Bit variables 0
*****************************************************/
//uncomment to use UART1
//#define UART1

#pragma promotechar+
#pragma uchar+
#pragma regalloc-
#pragma optsize+

#ifdef UART1
#include <cvmegaloaduart1.h> //contains defines for DeviceID FlashSize BootSize PageSize AddressLshift
#else
#include <cvmegaload.h> //contains defines for DeviceID FlashSize BootSize PageSize AddressLshift
#endif

#include <stdio.h>
//#define BAUDRATE 115200
#define BAUDRATE 9600
register unsigned int Pagedata @2; //program data to be written from this and read back for checking
register unsigned int PageAddress @4; //address of the page
register unsigned int CurrentAddress @6; //address of the current data -  PageAddress + loop counter
register char inchar @8; //data received from RS232 
register char spmcrval @10; //value to write to SPM control register 
register unsigned int i @11;   //loop counter
register unsigned int j @13;  //loop counter  
unsigned int ubbr;
unsigned int Checkdata ; //compared with Pagedata for checking
char PageBuffer[PageByte]; //buffer for data to be written   

#ifdef UART1

#define getchar getchar1
#define putchar putchar1

// Get a character from the USART1 Receiver
#pragma used+
char getchar(void) {
    char status,data;
    
    while (1) {
        while (((status=UCSRA) & 128)==0);
        data=UDR1;
        if ((status & (28))==0) return data;
    };
}
#pragma used-

// Write a character to the USART1 Transmitter
#pragma used+
void putchar(char c)
{
while ((UCSRA & 32)==0);
UDR1=c;
}
#pragma used-

#endif

char GetPage(void)
{
char LocalCheckSum = 0;
char CheckSum = 0;
// The programming software generates a simple checksum in the 
// same fashion as below to check for data transmission errors
for (j=0;j<PageByte;j++)
    {
    PageBuffer[j]=getchar();
    LocalCheckSum += PageBuffer[j];
    }
CheckSum = getchar();  
if (LocalCheckSum == CheckSum) return 1;
else return 0;
}

char CheckFlash(void)
{
//After the data has been written to flash it is read back and compared to the original
for (j=0;j<PageByte;j+=2)
    {
    CurrentAddress=PageAddress+j; 
    #if defined _CHIP_ATMEGA128_ 
    #asm
    movw r30, r6       ;//move  CurrentAddress to Z pointer  
    elpm r2, Z+         ;//read LSB
    elpm r3, Z           ;//read MSB    
    #endasm    
    #else
    #asm
    movw r30, r6       ;//move  CurrentAddress to Z pointer  
    lpm r2, Z+          ;//read LSB
    lpm r3, Z            ;//read MSB
    #endasm    
    #endif
    Checkdata = PageBuffer[j] +(PageBuffer[j+1]<<8);
    if (Pagedata != Checkdata) return 0;
    }
return 1;
}  

void ExecCode(void)
{
#if defined _CHIP_ATMEGA128_
RAMPZ =  0;  
#endif
MCUCR = 0x01;	       // Enable interrupt vector select
MCUCR = 0x00;	       // Move interrupt vector to flash
#asm("jmp 0x00"); // Run application code   
}

void BootLoad(void) { 
    // Send chip data to the programming software so that it knows
    // how to format transmissions
    putchar(DeviceID); 
    putchar(FlashSize);
    putchar(BootSize);
    putchar(PageSize);
    putchar(EEPromSize);  
    // "!" means all ok and send the next data if there is more
    putchar('!');
    while(1) {
        PageAddress = (unsigned int)getchar() << 8;  // Receive PageAddress high byte
        PageAddress += getchar();   // Add PageAddress low byte
        if (PageAddress == 0xffff) ExecCode(); // The windows program sends this value when finished  
        #if defined _CHIP_ATMEGA128_  
        if (PageAddress >> 8) RAMPZ =  1; else RAMPZ=0;  
        #endif
        PageAddress = PageAddress << AddressLshift; //essentially the same as multiply by PageSize
        if (GetPage()) {//receive one page of data followed by a checksum byte and verify data

            for (i=0;i<PageByte;i+=2) //fill temporary buffer in 2 byte chunks from PageBuffer       
            
                {
                Pagedata=PageBuffer[i]+(PageBuffer[i+1]<<8);
                while (SPMCR&1); //wait for spm complete
                CurrentAddress=PageAddress+i; 
                spmcrval=1;
                #asm 
                movw r30, r6    ;//move CurrentAddress to Z pointer   
                mov r1, r3        ;//move Pagedata MSB reg 1
                mov r0, r2        ;//move Pagedata LSB reg 1  
                sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
                spm                ;//store program memory
                #endasm
                }    
           
            while (SPMCR&1);  //wait for spm complete
            spmcrval=3;        //erase page
            #asm 
            movw r30, r4       ;//move PageAddress to Z pointer
            sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
            spm                 ;//erase page
            #endasm
              
            while (SPMCR&1); //wait for spm complete
            spmcrval=5;        //write page
            #asm 
            movw r30, r4       ;//move PageAddress to Z pointer
            sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
            spm                 ;//write page
            #endasm

            while (SPMCR&1);  //wait for spm complete
            spmcrval=0x11;   //enableRWW  see mega8 datasheet for explanation
             // P. 212 Section "Prevent reading the RWW section
             // during self-programming
            #asm 
            sts SpmcrAddr, r10   ;//move spmcrval to SPMCR              
            spm   
            #endasm
             if (CheckFlash()) putchar('!');  //all ok, send next page
             else putchar('@'); //there was an error, resend page
          //end if (GetPage()) 
        } else 
            putchar('@');  //there was an error ,resend page
    }
}

void main(void)
{    
// USART initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART Receiver: On
// USART Transmitter: On
// USART Mode: Asynchronous
// USART Baud rate: 9600
UCSRA=0x00;
UCSRB=0x18;
UCSRC=0x86;
//UBRRH=0x00;
//UBRRL=0x2F;   

ubbr = (unsigned long int)_MCU_CLOCK_FREQUENCY_ / (BAUDRATE * 16) - 1;
UBRRH=ubbr >> 8;
UBRRL = ubbr;

putchar('>'); //I'm here, talk to me

while ( (! (UCSRA&128)) &( i < 32000) ) i++; //wait for data in or timeout 
if (i < 32000)  inchar= getchar(); 

if (inchar == '<') BootLoad(); // I'm here too, go ahead and load the program to flash 
ExecCode();  // set up and jump to application
}
