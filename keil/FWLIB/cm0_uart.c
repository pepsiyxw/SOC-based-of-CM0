#include "cm0_uart.h"

void UART_Init(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t BaudRate,uint32_t tx_en,uint32_t rx_en)
{
	uint32_t new_ctrl=0;
	uint32_t divider=0;
//	uint32_t clock=0x2FAF080;//50000000Hz
//	uint32_t clock=0x2625A00;//40000000Hz
//	uint32_t clock=0x3473BC0;//60000000Hz
	uint32_t clock=0x23C3460;//37500000Hz
//	uint32_t clock=0x1FCA055;//33333333Hz
	
	if (tx_en!=0)        new_ctrl |= CMSDK_UART_CTRL_TXEN_Msk;
    if (rx_en!=0)        new_ctrl |= CMSDK_UART_CTRL_RXEN_Msk;
	
	CMSDK_UART->CTRL = 0;         /* Disable UART when changing configuration */
	divider = ((25 * clock)/(4 * BaudRate))/100 << 4;
    CMSDK_UART->BAUDDIV = divider;
    CMSDK_UART->CTRL = new_ctrl;  /* Update CTRL register to new value */
}

void UART_IRQInit(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t tx_irq_en, uint32_t rx_irq_en)
{
	uint32_t new_ctrl=0;
	if (tx_irq_en!=0)    new_ctrl |= CMSDK_UART_CTRL_TXIRQEN_Msk;
    if (rx_irq_en!=0)    new_ctrl |= CMSDK_UART_CTRL_RXIRQEN_Msk;
	CMSDK_UART->CTRL |= new_ctrl;
}

void UART_OvrIRQInit(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en)
{
	uint32_t new_ctrl=0;
	if (tx_ovrirq_en!=0) new_ctrl |= CMSDK_UART_CTRL_TXORIRQEN_Msk;
    if (rx_ovrirq_en!=0) new_ctrl |= CMSDK_UART_CTRL_RXORIRQEN_Msk;
	CMSDK_UART->CTRL |= new_ctrl;
}

uint32_t CMSDK_uart_init1(CMSDK_UART_TypeDef *CMSDK_UART, uint32_t divider, uint32_t tx_en,
                           uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en)
 {
       uint32_t new_ctrl=0;

       if (tx_en!=0)        new_ctrl |= CMSDK_UART_CTRL_TXEN_Msk;
       if (rx_en!=0)        new_ctrl |= CMSDK_UART_CTRL_RXEN_Msk;
       if (tx_irq_en!=0)    new_ctrl |= CMSDK_UART_CTRL_TXIRQEN_Msk;
       if (rx_irq_en!=0)    new_ctrl |= CMSDK_UART_CTRL_RXIRQEN_Msk;
       if (tx_ovrirq_en!=0) new_ctrl |= CMSDK_UART_CTRL_TXORIRQEN_Msk;
       if (rx_ovrirq_en!=0) new_ctrl |= CMSDK_UART_CTRL_RXORIRQEN_Msk;

       CMSDK_UART->CTRL = 0;         /* Disable UART when changing configuration */
       CMSDK_UART->BAUDDIV = divider;
       CMSDK_UART->CTRL = new_ctrl;  /* Update CTRL register to new value */

       if((CMSDK_UART->STATE & (CMSDK_UART_STATE_RXOR_Msk | CMSDK_UART_STATE_TXOR_Msk))) return 1;
       else return 0;
 }
 
void UART_SendChar(CMSDK_UART_TypeDef *CMSDK_UART, char txchar)
 {
       while(CMSDK_UART->STATE & CMSDK_UART_STATE_TXBF_Msk);
       CMSDK_UART->DATA = (uint32_t)txchar;
 }
 
void UART_SendByte(CMSDK_UART_TypeDef *CMSDK_UART, uint8_t Byte)
 {
       while(CMSDK_UART->STATE & CMSDK_UART_STATE_TXBF_Msk);
       CMSDK_UART->DATA = (uint32_t)Byte;
 }
 
char UART_ReceiveChar(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       while(!(CMSDK_UART->STATE & CMSDK_UART_STATE_RXBF_Msk));
       return (char)(CMSDK_UART->DATA);
 }
 
uint8_t UART_ReceiveByte(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       while(!(CMSDK_UART->STATE & CMSDK_UART_STATE_RXBF_Msk));
       return (uint8_t)(CMSDK_UART->DATA);
 }
 
void UART_SendArray(CMSDK_UART_TypeDef *CMSDK_UART,uint8_t *Array, uint16_t Length)
 {
	uint16_t i;
	for (i = 0; i < Length; i ++)
	{
		UART_SendByte(CMSDK_UART,Array[i]);
	}
 }
 
void UART_SendString(CMSDK_UART_TypeDef *CMSDK_UART,char * String)
 {
	uint8_t i;
	for (i = 0; String[i] != '\0'; i ++)
	{
		UART_SendChar(CMSDK_UART,String[i]);
	}
 }
 
uint32_t UART_Pow(uint32_t X, uint32_t Y)
{
	uint32_t Result = 1;
	while (Y --)
	{
		Result *= X;
	}
	return Result;
}
 
void UART_SendNumber(CMSDK_UART_TypeDef *CMSDK_UART,uint32_t Number, uint8_t Length)
{
	uint8_t i;
	for (i = 0; i < Length; i ++)
	{
		UART_SendByte(CMSDK_UART,Number / UART_Pow(10, Length - i - 1) % 10 + '0');
	}
}


uint32_t UART_GetBaudDivider(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       return CMSDK_UART->BAUDDIV;
 }
 
uint32_t UART_GetRxBufferFull(CMSDK_UART_TypeDef *CMSDK_UART)
 {
        return ((CMSDK_UART->STATE & CMSDK_UART_STATE_RXBF_Msk)>> CMSDK_UART_STATE_RXBF_Pos);
 }
 
uint32_t UART_GetTxBufferFull(CMSDK_UART_TypeDef *CMSDK_UART)
 {
        return ((CMSDK_UART->STATE & CMSDK_UART_STATE_TXBF_Msk)>> CMSDK_UART_STATE_TXBF_Pos);
 }
 
void UART_ClearTxIRQ(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       CMSDK_UART->INTCLEAR = CMSDK_UART_CTRL_TXIRQ_Msk;
 }
 
void UART_ClearRxIRQ(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       CMSDK_UART->INTCLEAR = CMSDK_UART_CTRL_RXIRQ_Msk;
 }
 
void UART_ClearTxorrIRQ(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       CMSDK_UART->INTCLEAR = CMSDK_UART_CTRL_TXORIRQ_Msk;
 }
 
void UART_ClearRxorIRQ(CMSDK_UART_TypeDef *CMSDK_UART)
 {
       CMSDK_UART->INTCLEAR = CMSDK_UART_CTRL_RXORIRQ_Msk;
 }

