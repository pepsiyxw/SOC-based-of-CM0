;/**************************************************************************//**
; * @file     startup_CMSDK_CM0.s
; * @brief    CMSIS Cortex-M0 Core Device Startup File for
; *           Device CMSDK_CM0
; * @version  V3.01
; * @date     06. March 2012
; *
; * @note
; * Copyright (C) 2012 ARM Limited. All rights reserved.
; *
; * @par
; * ARM Limited (ARM) is supplying this software for use with Cortex-M
; * processor based microcontrollers.  This file can be freely distributed
; * within development tools that are supporting such ARM based processors.
; *
; * @par
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; ******************************************************************************/
;/*
;//-------- <<< Use Configuration Wizard in Context Menu >>> ------------------
;*/


; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000200

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000100

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                DCD     UARTRX0_Handler           ; UART 0 RX Handler
                DCD     UARTTX0_Handler           ; UART 0 TX Handler
                DCD     UARTRX1_Handler           ; UART 1 RX Handler
                DCD     UARTTX1_Handler           ; UART 1 TX Handler
                DCD     UARTRX2_Handler           ; UART 2 RX Handler
                DCD     UARTTX2_Handler           ; UART 2 TX Handler
                DCD     SPTIMER0_Handler          ; SPTIMER0 Handler
                DCD     SPTIMER1_Handler          ; SPTIMER1 Handler
				DCD     EXIT_Handler0			  ;
				DCD     EXIT_Handler1             ;
				DCD     EXIT_Handler2             ;
				DCD     EXIT_Handler3             ;
				DCD     EXIT_Handler4             ;
				DCD     EXIT_Handler5             ;
				DCD     EXIT_Handler6             ;
				DCD     EXIT_Handler7             ;
				DCD     EXIT_Handler8             ;

__Vectors_End

__Vectors_Size  EQU     __Vectors_End - __Vectors

                AREA    |.text|, CODE, READONLY


; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
                IMPORT  SystemInit
                IMPORT  __main
                LDR     R0, =SystemInit
                ; Initialise at least r8, r9 to avoid X in tests
                ; Only important for simulation where X can cause
                ; unexpected core behaviour
                MOV     R8, R0
                MOV     R9, R8
                BLX     R0
                LDR     R0, =__main
                BX      R0
                ENDP


; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
				EXPORT  SysTick_Handler            [WEAK]
				B       .
				ENDP	   
UARTRX0_Handler PROC
                EXPORT  UARTRX0_Handler               [WEAK]
                IMPORT  UARTRX0Handler
                PUSH    {R0,R1,R2,LR}
                BL      UARTRX0Handler
                POP     {R0,R1,R2,PC}
                ENDP
UARTTX0_Handler PROC
                EXPORT  UARTTX0_Handler               [WEAK]
                IMPORT  UARTTX0Handler
                PUSH    {R0,R1,R2,LR}
                BL      UARTTX0Handler
                POP     {R0,R1,R2,PC}
                ENDP
UARTRX1_Handler PROC
                EXPORT  UARTRX1_Handler               [WEAK]
                IMPORT  UARTRX1Handler
                PUSH    {R0,R1,R2,LR}
                BL      UARTRX1Handler
                POP     {R0,R1,R2,PC}
                ENDP
UARTTX1_Handler PROC
                EXPORT  UARTTX1_Handler               [WEAK]
                IMPORT  UARTTX1Handler
                PUSH    {R0,R1,R2,LR}
                BL      UARTTX1Handler
                POP     {R0,R1,R2,PC}
                ENDP
UARTRX2_Handler PROC
                EXPORT  UARTRX2_Handler               [WEAK]
                IMPORT  UARTRX2Handler
                PUSH    {R0,R1,R2,LR}
                BL      UARTRX2Handler
                POP     {R0,R1,R2,PC}
                ENDP
UARTTX2_Handler PROC
                EXPORT  UARTTX2_Handler               [WEAK]
                IMPORT  UARTTX2Handler
                PUSH    {R0,R1,R2,LR}
                BL      UARTTX2Handler
                POP     {R0,R1,R2,PC}
                ENDP
SPTIMER0_Handler\
				PROC
                EXPORT  SPTIMER0_Handler               [WEAK]
                IMPORT  SPTIMER0Handler
                PUSH    {R0,R1,R2,LR}
                BL      SPTIMER0Handler
                POP     {R0,R1,R2,PC}
                ENDP
SPTIMER1_Handler\
				PROC
                EXPORT  SPTIMER1_Handler               [WEAK]
                IMPORT  SPTIMER1Handler
                PUSH    {R0,R1,R2,LR}
                BL      SPTIMER1Handler
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler0   PROC
                EXPORT  EXIT_Handler0               [WEAK]
                IMPORT  EXITHandler0
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler0
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler1   PROC
                EXPORT  EXIT_Handler1               [WEAK]
                IMPORT  EXITHandler1
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler1
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler2   PROC
                EXPORT  EXIT_Handler2               [WEAK]
                IMPORT  EXITHandler2
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler2
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler3   PROC
                EXPORT  EXIT_Handler3               [WEAK]
                IMPORT  EXITHandler3
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler3
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler4   PROC
                EXPORT  EXIT_Handler4               [WEAK]
                IMPORT  EXITHandler4
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler4
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler5   PROC
                EXPORT  EXIT_Handler5               [WEAK]
                IMPORT  EXITHandler5
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler5
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler6   PROC
                EXPORT  EXIT_Handler6               [WEAK]
                IMPORT  EXITHandler6
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler6
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler7   PROC
                EXPORT  EXIT_Handler7               [WEAK]
                IMPORT  EXITHandler7
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler7
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler8   PROC
                EXPORT  EXIT_Handler8               [WEAK]
                IMPORT  EXITHandler8
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler8
                POP     {R0,R1,R2,PC}
                ENDP
EXIT_Handler9   PROC
                EXPORT  EXIT_Handler9               [WEAK]
                IMPORT  EXITHandler9
                PUSH    {R0,R1,R2,LR}
                BL      EXITHandler9
                POP     {R0,R1,R2,PC}
                ENDP

                ALIGN


; User Initial Stack & Heap

                IF      :DEF:__MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap

__user_initial_stackheap PROC
                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDP

                ALIGN

                ENDIF


                END
