#ifndef _CM0_UART_H
#define _CM0_UART_H

#include "CMSDK_CM0.h"

#define		UART0		CMSDK_UART0
#define		UART1		CMSDK_UART1
#define		UART2		CMSDK_UART2

void UART_Init(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t BaudRate,uint32_t tx_en,uint32_t rx_en);
void UART_IRQInit(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t tx_irq_en, uint32_t rx_irq_en);
void UART_OvrIRQInit(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en);

void UART_SendChar(CMSDK_UART_TypeDef *CMSDK_UART, char txchar);
void UART_SendByte(CMSDK_UART_TypeDef *CMSDK_UART, uint8_t Byte);
char UART_ReceiveChar(CMSDK_UART_TypeDef *CMSDK_UART);
uint8_t UART_ReceiveByte(CMSDK_UART_TypeDef *CMSDK_UART);

void UART_SendArray(CMSDK_UART_TypeDef *CMSDK_UART,uint8_t *Array, uint16_t Length);
void UART_SendString(CMSDK_UART_TypeDef *CMSDK_UART,char * String);
void UART_SendNumber(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t Number, uint8_t Length);

uint32_t UART_GetBaudDivider(CMSDK_UART_TypeDef *CMSDK_UART);
uint32_t UART_GetRxBufferFull(CMSDK_UART_TypeDef *CMSDK_UART);
uint32_t UART_GetTxBufferFull(CMSDK_UART_TypeDef *CMSDK_UART);

void UART_ClearTxIRQ(CMSDK_UART_TypeDef *CMSDK_UART);
void UART_ClearRxIRQ(CMSDK_UART_TypeDef *CMSDK_UART);
void UART_ClearTxorrIRQ(CMSDK_UART_TypeDef *CMSDK_UART);
void UART_ClearRxorIRQ(CMSDK_UART_TypeDef *CMSDK_UART);

#endif
