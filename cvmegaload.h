#define	 BootSize	 'c'    // 512 Words
#if defined _CHIP_ATMEGA8_
#define	 DeviceID  	 'A'	// Mega8		
#define	 FlashSize	 'l'    // Flash 8k
#define	 PageSize	 'R'    // 64 Bytes
#define  PageByte 	 64     // 64 Bytes
#define  AddressLshift    6 
#asm(".EQU SpmcrAddr=0x57")
#include <mega8.h>

#elif defined _CHIP_ATMEGA16_
#define	 DeviceID  	 'B'	// Mega16	
#define	 FlashSize	 'm'    // Flash 16k
#define	 PageSize	 'S'    // 128 Bytes
#define  PageByte 	 128     // 128 Bytes
#define  AddressLshift    7
#asm(".EQU SpmcrAddr=0x57")
#include <mega16.h>

#elif defined _CHIP_ATMEGA32_
#define  DeviceID	 'E'	// Mega32
#define	 FlashSize	 'n'    // Flash 32k
#define	 PageSize	 'S'    // 128 Bytes
#define  PageByte 	 128     // 128 Bytes
#define  EEPromSize  '2'    // 1024
#define  AddressLshift    7
#asm(".EQU SpmcrAddr=0x57")
#include <mega32.h>

#elif defined _CHIP_ATMEGA8515_
#define	 DeviceID  	 'H'	// Mega8515
#define	 FlashSize	 'l'    // Flash 8k
#define	 PageSize	 'R'    // 64 Bytes
#define  PageByte 	 64     // 64 Bytes
#define  AddressLshift    6
#asm(".EQU SpmcrAddr=0x57")
#include <mega8515.h>

#elif defined _CHIP_ATMEGA8535_
#define	 DeviceID  	 'I'	// Mega8535
#define	 FlashSize	 'l'    // Flash 8k
#define	 PageSize	 'R'    // 64 Bytes
#define  PageByte 	 64     // 64 Bytes
#define  AddressLshift    6
#asm(".EQU SpmcrAddr=0x57")
#include <mega8535.h>

#elif defined _CHIP_ATMEGA88_
#define	 DeviceID  	 'M'	// Mega88
#define	 FlashSize	 'l'    // Flash 8k
#define	 PageSize	 'R'    // 64 Bytes
#define  PageByte 	 64     // 64 Bytes
#define  AddressLshift    6
#asm(".EQU SpmcrAddr=0x57")
#include <mega88.h>

#elif defined _CHIP_ATMEGA168_
#define	 DeviceID  	 'N'	// Mega168
#define	 FlashSize	 'm'    // Flash 16k
#define	 PageSize	 'R'    // 64 Bytes
#define  PageByte 	 64     // 64 Bytes
#define  AddressLshift    6
#asm(".EQU SpmcrAddr=0x57")
#include <mega168.h>   

#elif defined _CHIP_ATMEGA64_
#define	 DeviceID  	 'C'	// Mega64	
#define	 FlashSize	 'o'    // Flash 64k
#define	 PageSize	 'T'    // 256 Bytes		
#define  PageByte 	 256     // 256 Bytes
#define  AddressLshift    8
#define SPMCR SPMCSR
#define UCSRA UCSR0A
#define UCSRB UCSR0B 
#define UCSRC UCSR0C
#define UBRRH UBRR0H
#define UBRRL UBRR0L
#asm(".EQU SpmcrAddr=0x68")
#include <mega64.h>

#elif defined _CHIP_ATMEGA128_
#define	 DeviceID  	 'D'	// Mega128	
#define	 FlashSize	 'p'    // Flash 128k
#define	 PageSize	 'T'    // 256 Bytes
#define  PageByte 	 256     // 256 Bytes
#define  AddressLshift    8
#define UCSRA UCSR0A
#define UCSRB UCSR0B 
#define UCSRC UCSR0C
#define UBRRH UBRR0H
#define UBRRL UBRR0L
#define SPMCR SPMCSR
#asm(".EQU SpmcrAddr=0x68")
#include <mega128.h>

#elif defined _CHIP_ATMEGA169_
#define	 DeviceID  	 'G'	// Mega169
#define	 FlashSize	 'm'    // Flash 16k
#define	 PageSize	 'S'    // 128 Bytes
#define  PageByte 	 128     // 128 Bytes
#define  AddressLshift    7
#define SPMCR SPMCSR
#define UCSRA UCSR0A
#define UCSRB UCSR0B 
#define UCSRC UCSR0C
#define UBRRH UBRR0H
#define UBRRL UBRR0L
#asm(".EQU SpmcrAddr=0x57")
#include <mega169.h>

#elif defined _CHIP_ATMEGA162_
#define	 DeviceID  	 'F'	// Mega162
#define	 FlashSize	 'm'    // Flash 16k
#define	 PageSize	 'S'    // 128 Bytes
#define  PageByte 	 128     // 128 Bytes
#define  AddressLshift    7
#define UCSRA UCSR0A
#define UCSRB UCSR0B 
#define UCSRC UCSR0C
#define UBRRH UBRR0H
#define UBRRL UBRR0L
#asm(".EQU SpmcrAddr=0x57")
#include <mega162.h>

#endif




