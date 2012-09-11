
;CodeVisionAVR C Compiler V2.03.9 Standard
;(C) Copyright 1998-2008 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type              : ATmega32
;Program type           : Boot Loader
;Clock frequency        : 3,686400 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 512 byte(s)
;Heap size              : 0 byte(s)
;Promote char to int    : Yes
;char is unsigned       : Yes
;global const stored in FLASH  : No
;8 bit enums            : Yes
;Enhanced core instructions    : On
;Smart register allocation : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega32
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2048
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+@1
	ANDI R30,LOW(@2)
	STS  @0+@1,R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+@1
	ANDI R30,LOW(@2)
	STS  @0+@1,R30
	LDS  R30,@0+@1+1
	ANDI R30,HIGH(@2)
	STS  @0+@1+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+@1
	ORI  R30,LOW(@2)
	STS  @0+@1,R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+@1
	ORI  R30,LOW(@2)
	STS  @0+@1,R30
	LDS  R30,@0+@1+1
	ORI  R30,HIGH(@2)
	STS  @0+@1+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+@1)
	LDI  R31,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	LDI  R22,BYTE3(2*@0+@1)
	LDI  R23,BYTE4(2*@0+@1)
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+@1)
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+@2)
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+@3)
	LDI  R@1,HIGH(@2+@3)
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+@3)
	LDI  R@1,HIGH(@2*2+@3)
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+@1
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+@1
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	LDS  R22,@0+@1+2
	LDS  R23,@0+@1+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+@2
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+@3
	LDS  R@1,@2+@3+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+@1
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+@1
	LDS  R27,@0+@1+1
	LDS  R24,@0+@1+2
	LDS  R25,@0+@1+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+@1,R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+@1,R30
	STS  @0+@1+1,R31
	STS  @0+@1+2,R22
	STS  @0+@1+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+@1,R0
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+@1,R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+@1,R@2
	STS  @0+@1+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+@1
	LDS  R31,@0+@1+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+@1)
	LDI  R31,HIGH(2*@0+@1)
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+@1)
	LDI  R27,HIGH(@0+@1)
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R@1
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _PageAddress=R4
	.DEF _CurrentAddress=R6
	.DEF _inchar=R8
	.DEF _spmcrval=R10
	.DEF _i=R11
	.DEF _j=R13

	.CSEG
	.ORG 0x3E00

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00
	JMP  0x3E00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF THE BOOT LOADER
	LDI  R31,1
	OUT  GICR,R31
	LDI  R31,2
	OUT  GICR,R31
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(0x800)
	LDI  R25,HIGH(0x800)
	LDI  R26,0x60
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;STACK POINTER INITIALIZATION
	LDI  R30,LOW(0x85F)
	OUT  SPL,R30
	LDI  R30,HIGH(0x85F)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(0x260)
	LDI  R29,HIGH(0x260)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x260

	.CSEG
;/*****************************************************
;Project :   CVMegaload
;Version :   1.00
;Date    : 14/05/2004
;Author  : Ralph Hilton
;Chip type           : ATmega
;Program type        : Bootloader
;Clock frequency     : 7.372800 MHz
;Data Stack size     : 256
;Acknowledgement  : Modified from original code by Sylvain Bissonnette
;*****************************************************/
;/*****************************************************
;Note: BAUDRATE must be correctly defined below
;Supported values are
;9600 19200 38400 57600 115200
;Chip header is included by cvmegaload.h from the project configuration
;// The project should be compiled with the following compiler options:
;// Promote char to int
;// Char is unsigned
;// Bit variables 0
;*****************************************************/
;//uncomment to use UART1
;//#define UART1
;
;#pragma promotechar+
;#pragma uchar+
;#pragma regalloc-
;#pragma optsize+
;
;#ifdef UART1
;#include <cvmegaloaduart1.h> //contains defines for DeviceID FlashSize BootSize PageSize AddressLshift
;#else
;#include <cvmegaload.h> //contains defines for DeviceID FlashSize BootSize PageSize AddressLshift
	.EQU SpmcrAddr=0x57
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;#endif
;
;#include <stdio.h>
;#define BAUDRATE 115200
;//#define BAUDRATE 9600
;register unsigned int Pagedata @2; //program data to be written from this and read back for checking
;register unsigned int PageAddress @4; //address of the page
;register unsigned int CurrentAddress @6; //address of the current data -  PageAddress + loop counter
;register char inchar @8; //data received from RS232
;register char spmcrval @10; //value to write to SPM control register
;register unsigned int i @11;   //loop counter
;register unsigned int j @13;  //loop counter
;unsigned int ubbr;
;unsigned int Checkdata ; //compared with Pagedata for checking
;char PageBuffer[PageByte]; //buffer for data to be written
;
;#ifdef UART1
;
;#define getchar getchar1
;#define putchar putchar1
;
;// Get a character from the USART1 Receiver
;#pragma used+
;char getchar(void) {
;    char status,data;
;
;    while (1) {
;        while (((status=UCSRA) & 128)==0);
;        data=UDR1;
;        if ((status & (28))==0) return data;
;    };
;}
;#pragma used-
;
;// Write a character to the USART1 Transmitter
;#pragma used+
;void putchar(char c)
;{
;while ((UCSRA & 32)==0);
;UDR1=c;
;}
;#pragma used-
;
;#endif
;
;char GetPage(void)
; 0000 0050 {

	.CSEG
_GetPage:
; 0000 0051 char LocalCheckSum = 0;
; 0000 0052 char CheckSum = 0;
; 0000 0053 // The programming software generates a simple checksum in the
; 0000 0054 // same fashion as below to check for data transmission errors
; 0000 0055 for (j=0;j<PageByte;j++)
	ST   -Y,R17
	ST   -Y,R16
;	LocalCheckSum -> R17
;	CheckSum -> R16
	LDI  R17,0
	LDI  R16,0
	CLR  R13
	CLR  R14
_0x4:
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CP   R13,R30
	CPC  R14,R31
	BRSH _0x5
; 0000 0056     {
; 0000 0057     PageBuffer[j]=getchar();
	__GETW1R 13,14
	SUBI R30,LOW(-_PageBuffer)
	SBCI R31,HIGH(-_PageBuffer)
	PUSH R31
	PUSH R30
	CALL _getchar
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0058     LocalCheckSum += PageBuffer[j];
	MOV  R0,R17
	CLR  R1
	LDI  R26,LOW(_PageBuffer)
	LDI  R27,HIGH(_PageBuffer)
	ADD  R26,R13
	ADC  R27,R14
	LD   R30,X
	LDI  R31,0
	MOVW R26,R0
	ADD  R30,R26
	MOV  R17,R30
; 0000 0059     }
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__ADDWRR 13,14,30,31
	RJMP _0x4
_0x5:
; 0000 005A CheckSum = getchar();
	CALL _getchar
	MOV  R16,R30
; 0000 005B if (LocalCheckSum == CheckSum) return 1;
	CP   R16,R17
	BRNE _0x6
	LDI  R30,LOW(1)
	RJMP _0x2060001
; 0000 005C else return 0;
_0x6:
	LDI  R30,LOW(0)
; 0000 005D }
_0x2060001:
	LD   R16,Y+
	LD   R17,Y+
	RET
;
;char CheckFlash(void)
; 0000 0060 {
_CheckFlash:
; 0000 0061 //After the data has been written to flash it is read back and compared to the original
; 0000 0062 for (j=0;j<PageByte;j+=2)
	CLR  R13
	CLR  R14
_0x9:
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CP   R13,R30
	CPC  R14,R31
	BRSH _0xA
; 0000 0063     {
; 0000 0064     CurrentAddress=PageAddress+j;
	__GETW1R 13,14
	ADD  R30,R4
	ADC  R31,R5
	MOVW R6,R30
; 0000 0065     #if defined _CHIP_ATMEGA128_
; 0000 0066     #asm
; 0000 0067     movw r30, r6       ;//move  CurrentAddress to Z pointer
; 0000 0068     elpm r2, Z+         ;//read LSB
; 0000 0069     elpm r3, Z           ;//read MSB
; 0000 006A     #endasm
; 0000 006B     #else
; 0000 006C     #asm
; 0000 006D     movw r30, r6       ;//move  CurrentAddress to Z pointer
    movw r30, r6       ;//move  CurrentAddress to Z pointer
; 0000 006E     lpm r2, Z+          ;//read LSB
    lpm r2, Z+          ;//read LSB
; 0000 006F     lpm r3, Z            ;//read MSB
    lpm r3, Z            ;//read MSB
; 0000 0070     #endasm
; 0000 0071     #endif
; 0000 0072     Checkdata = PageBuffer[j] +(PageBuffer[j+1]<<8);
	LDI  R26,LOW(_PageBuffer)
	LDI  R27,HIGH(_PageBuffer)
	ADD  R26,R13
	ADC  R27,R14
	LD   R26,X
	CLR  R27
	__GETW1R 13,14
	CALL SUBOPT_0x0
	STS  _Checkdata,R30
	STS  _Checkdata+1,R31
; 0000 0073     if (Pagedata != Checkdata) return 0;
	CP   R30,R2
	CPC  R31,R3
	BREQ _0xB
	LDI  R30,LOW(0)
	RET
; 0000 0074     }
_0xB:
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	__ADDWRR 13,14,30,31
	RJMP _0x9
_0xA:
; 0000 0075 return 1;
	LDI  R30,LOW(1)
	RET
; 0000 0076 }
;
;void ExecCode(void)
; 0000 0079 {
_ExecCode:
; 0000 007A #if defined _CHIP_ATMEGA128_
; 0000 007B RAMPZ =  0;
; 0000 007C #endif
; 0000 007D MCUCR = 0x01;	       // Enable interrupt vector select
	LDI  R30,LOW(1)
	OUT  0x35,R30
; 0000 007E MCUCR = 0x00;	       // Move interrupt vector to flash
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 007F #asm("jmp 0x00"); // Run application code
	jmp 0x00
; 0000 0080 }
	RET
;
;void BootLoad(void) {
; 0000 0082 void BootLoad(void) {
_BootLoad:
; 0000 0083     // Send chip data to the programming software so that it knows
; 0000 0084     // how to format transmissions
; 0000 0085     putchar(DeviceID);
	LDI  R30,LOW(69)
	ST   -Y,R30
	CALL _putchar
; 0000 0086     putchar(FlashSize);
	LDI  R30,LOW(110)
	ST   -Y,R30
	CALL _putchar
; 0000 0087     putchar(BootSize);
	LDI  R30,LOW(99)
	ST   -Y,R30
	CALL _putchar
; 0000 0088     putchar(PageSize);
	LDI  R30,LOW(83)
	ST   -Y,R30
	CALL _putchar
; 0000 0089     putchar(EEPromSize);
	LDI  R30,LOW(50)
	ST   -Y,R30
	CALL _putchar
; 0000 008A     // "!" means all ok and send the next data if there is more
; 0000 008B     putchar('!');
	LDI  R30,LOW(33)
	ST   -Y,R30
	CALL _putchar
; 0000 008C     while(1) {
_0xC:
; 0000 008D         PageAddress = (unsigned int)getchar() << 8;  // Receive PageAddress high byte
	CALL _getchar
	MOV  R31,R30
	LDI  R30,0
	MOVW R4,R30
; 0000 008E         PageAddress += getchar();   // Add PageAddress low byte
	CALL _getchar
	LDI  R31,0
	__ADDWRR 4,5,30,31
; 0000 008F         if (PageAddress == 0xffff) ExecCode(); // The windows program sends this value when finished
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	CP   R30,R4
	CPC  R31,R5
	BRNE _0xF
	RCALL _ExecCode
; 0000 0090         #if defined _CHIP_ATMEGA128_
; 0000 0091         if (PageAddress >> 8) RAMPZ =  1; else RAMPZ=0;
; 0000 0092         #endif
; 0000 0093         PageAddress = PageAddress << AddressLshift; //essentially the same as multiply by PageSize
_0xF:
	MOVW R26,R4
	LDI  R30,LOW(7)
	CALL __LSLW12
	MOVW R4,R30
; 0000 0094         if (GetPage()) {//receive one page of data followed by a checksum byte and verify data
	RCALL _GetPage
	CPI  R30,0
	BRNE PC+3
	JMP _0x10
; 0000 0095 
; 0000 0096             for (i=0;i<PageByte;i+=2) //fill temporary buffer in 2 byte chunks from PageBuffer
	CLR  R11
	CLR  R12
_0x12:
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CP   R11,R30
	CPC  R12,R31
	BRSH _0x13
; 0000 0097 
; 0000 0098                 {
; 0000 0099                 Pagedata=PageBuffer[i]+(PageBuffer[i+1]<<8);
	LDI  R26,LOW(_PageBuffer)
	LDI  R27,HIGH(_PageBuffer)
	ADD  R26,R11
	ADC  R27,R12
	LD   R26,X
	CLR  R27
	__GETW1R 11,12
	CALL SUBOPT_0x0
	MOVW R2,R30
; 0000 009A                 while (SPMCR&1); //wait for spm complete
_0x14:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x14
; 0000 009B                 CurrentAddress=PageAddress+i;
	__GETW1R 11,12
	ADD  R30,R4
	ADC  R31,R5
	MOVW R6,R30
; 0000 009C                 spmcrval=1;
	LDI  R30,LOW(1)
	MOV  R10,R30
; 0000 009D                 #asm
; 0000 009E                 movw r30, r6    ;//move CurrentAddress to Z pointer
                movw r30, r6    ;//move CurrentAddress to Z pointer
; 0000 009F                 mov r1, r3        ;//move Pagedata MSB reg 1
                mov r1, r3        ;//move Pagedata MSB reg 1
; 0000 00A0                 mov r0, r2        ;//move Pagedata LSB reg 1
                mov r0, r2        ;//move Pagedata LSB reg 1
; 0000 00A1                 sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
                sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
; 0000 00A2                 spm                ;//store program memory
                spm                ;//store program memory
; 0000 00A3                 #endasm
; 0000 00A4                 }
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	__ADDWRR 11,12,30,31
	RJMP _0x12
_0x13:
; 0000 00A5 
; 0000 00A6             while (SPMCR&1);  //wait for spm complete
_0x17:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x17
; 0000 00A7             spmcrval=3;        //erase page
	LDI  R30,LOW(3)
	MOV  R10,R30
; 0000 00A8             #asm
; 0000 00A9             movw r30, r4       ;//move PageAddress to Z pointer
            movw r30, r4       ;//move PageAddress to Z pointer
; 0000 00AA             sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
            sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
; 0000 00AB             spm                 ;//erase page
            spm                 ;//erase page
; 0000 00AC             #endasm
; 0000 00AD 
; 0000 00AE             while (SPMCR&1); //wait for spm complete
_0x1A:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x1A
; 0000 00AF             spmcrval=5;        //write page
	LDI  R30,LOW(5)
	MOV  R10,R30
; 0000 00B0             #asm
; 0000 00B1             movw r30, r4       ;//move PageAddress to Z pointer
            movw r30, r4       ;//move PageAddress to Z pointer
; 0000 00B2             sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
            sts SpmcrAddr, r10    ;//move spmcrval to SPM control register
; 0000 00B3             spm                 ;//write page
            spm                 ;//write page
; 0000 00B4             #endasm
; 0000 00B5 
; 0000 00B6             while (SPMCR&1);  //wait for spm complete
_0x1D:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x1D
; 0000 00B7             spmcrval=0x11;   //enableRWW  see mega8 datasheet for explanation
	LDI  R30,LOW(17)
	MOV  R10,R30
; 0000 00B8              // P. 212 Section "Prevent reading the RWW section
; 0000 00B9              // during self-programming
; 0000 00BA             #asm
; 0000 00BB             sts SpmcrAddr, r10   ;//move spmcrval to SPMCR
            sts SpmcrAddr, r10   ;//move spmcrval to SPMCR
; 0000 00BC             spm
            spm
; 0000 00BD             #endasm
; 0000 00BE              if (CheckFlash()) putchar('!');  //all ok, send next page
	CALL _CheckFlash
	CPI  R30,0
	BREQ _0x20
	LDI  R30,LOW(33)
	RJMP _0x29
; 0000 00BF              else putchar('@'); //there was an error, resend page
_0x20:
	LDI  R30,LOW(64)
_0x29:
	ST   -Y,R30
	RCALL _putchar
; 0000 00C0           //end if (GetPage())
; 0000 00C1         } else
	RJMP _0x22
_0x10:
; 0000 00C2             putchar('@');  //there was an error ,resend page
	LDI  R30,LOW(64)
	ST   -Y,R30
	RCALL _putchar
; 0000 00C3     }
_0x22:
	RJMP _0xC
; 0000 00C4 }
;
;void main(void)
; 0000 00C7 {
_main:
; 0000 00C8 // USART initialization
; 0000 00C9 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 00CA // USART Receiver: On
; 0000 00CB // USART Transmitter: On
; 0000 00CC // USART Mode: Asynchronous
; 0000 00CD // USART Baud rate: 9600
; 0000 00CE UCSRA=0x00;
	LDI  R30,LOW(0)
	OUT  0xB,R30
; 0000 00CF UCSRB=0x18;
	LDI  R30,LOW(24)
	OUT  0xA,R30
; 0000 00D0 UCSRC=0x86;
	LDI  R30,LOW(134)
	OUT  0x20,R30
; 0000 00D1 //UBRRH=0x00;
; 0000 00D2 //UBRRL=0x2F;
; 0000 00D3 
; 0000 00D4 ubbr = (unsigned long int)_MCU_CLOCK_FREQUENCY_ / (BAUDRATE * 16) - 1;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _ubbr,R30
	STS  _ubbr+1,R31
; 0000 00D5 UBRRH=ubbr >> 8;
	LDS  R30,_ubbr+1
	ANDI R31,HIGH(0x0)
	OUT  0x20,R30
; 0000 00D6 UBRRL = ubbr;
	LDS  R30,_ubbr
	LDS  R31,_ubbr+1
	OUT  0x9,R30
; 0000 00D7 
; 0000 00D8 putchar('>'); //I'm here, talk to me
	LDI  R30,LOW(62)
	ST   -Y,R30
	RCALL _putchar
; 0000 00D9 
; 0000 00DA while ( (! (UCSRA&128)) &( i < 32000) ) i++; //wait for data in or timeout
_0x23:
	IN   R30,0xB
	ANDI R30,LOW(0x80)
	CALL __LNEGB1
	MOV  R0,R30
	__GETW2R 11,12
	LDI  R30,LOW(32000)
	LDI  R31,HIGH(32000)
	CALL __LTW12U
	AND  R30,R0
	BREQ _0x25
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__ADDWRR 11,12,30,31
	RJMP _0x23
_0x25:
; 0000 00DB if (i < 32000)  inchar= getchar();
	LDI  R30,LOW(32000)
	LDI  R31,HIGH(32000)
	CP   R11,R30
	CPC  R12,R31
	BRSH _0x26
	RCALL _getchar
	MOV  R8,R30
; 0000 00DC 
; 0000 00DD if (inchar == '<') BootLoad(); // I'm here too, go ahead and load the program to flash
_0x26:
	LDI  R30,LOW(60)
	CP   R30,R8
	BRNE _0x27
	RCALL _BootLoad
; 0000 00DE ExecCode();  // set up and jump to application
_0x27:
	RCALL _ExecCode
; 0000 00DF }
_0x28:
	RJMP _0x28
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_getchar:
     sbis usr,rxc
     rjmp _getchar
     in   r30,udr
	RET
_putchar:
     sbis usr,udre
     rjmp _putchar
     ld   r30,y
     out  udr,r30
	ADIW R28,1
	RET

	.CSEG

	.CSEG

	.DSEG
_ubbr:
	.BYTE 0x2
_Checkdata:
	.BYTE 0x2
_PageBuffer:
	.BYTE 0x80
_p_S1020024:
	.BYTE 0x2

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	__ADDW1MN _PageBuffer,1
	LD   R31,Z
	LDI  R30,LOW(0)
	ADD  R30,R26
	ADC  R31,R27
	RET


	.CSEG
__LSLW12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	BREQ __LSLW12R
__LSLW12L:
	LSL  R30
	ROL  R31
	DEC  R0
	BRNE __LSLW12L
__LSLW12R:
	RET

__LTW12U:
	CP   R26,R30
	CPC  R27,R31
	LDI  R30,1
	BRLO __LTW12UT
	CLR  R30
__LTW12UT:
	RET

__LNEGB1:
	TST  R30
	LDI  R30,1
	BREQ __LNEGB1F
	CLR  R30
__LNEGB1F:
	RET

;END OF CODE MARKER
__END_OF_CODE:
