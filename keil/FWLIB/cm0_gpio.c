#include "cm0_gpio.h"

void GPIO_Init(CMSDK_GPIO_TypeDef * GPIOx, GPIO_InitTypeDef *pGPIO){
	GPIOx->OUTENABLESET |= pGPIO->GPIO_Pin;
	GPIOx->ALTFUNCSET |= pGPIO->GPIO_AltFun;
	
  switch(pGPIO->GPIO_IRQ){
		case GPIO_IRQ_FallingEdge:{
			GPIOx->INTENSET	|= pGPIO->GPIO_Pin;
			GPIOx->INTTYPESET |= pGPIO->GPIO_Pin;
			GPIOx->INTPOLCLR  |= pGPIO->GPIO_Pin;
			break;
		}
		case GPIO_IRQ_RisingEdge:{
			GPIOx->INTENSET	|= pGPIO->GPIO_Pin;
			GPIOx->INTTYPESET |= pGPIO->GPIO_Pin;
			GPIOx->INTPOLSET  |= pGPIO->GPIO_Pin;
			break;
		}
		case GPIO_IRQ_HighLevel:{
			GPIOx->INTENSET	|= pGPIO->GPIO_Pin;
			GPIOx->INTTYPECLR |= pGPIO->GPIO_Pin;
			GPIOx->INTPOLSET  |= pGPIO->GPIO_Pin;
			break;
		}
		case GPIO_IRQ_LowLevel:{
			GPIOx->INTENSET	|= pGPIO->GPIO_Pin;
			GPIOx->INTTYPECLR |= pGPIO->GPIO_Pin;
			GPIOx->INTPOLCLR  |= pGPIO->GPIO_Pin;
			break;
		}
	}
}

void GPIO_SetOutput(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin){
	GPIOx->DATAOUT |= pin;
}

void GPIO_ClrOutput(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin){
	GPIOx->DATAOUT &= ~pin;
}

void GPIO_SetAltFun(CMSDK_GPIO_TypeDef * GPIOx, uint32_t op){
	GPIOx->ALTFUNCSET |= op;
}
void GPIO_SetOutputEnable(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin, FunctionalState state){
	if(state == ENABLE){
		GPIOx->OUTENABLESET |= pin;
	}
	else{
		GPIOx->OUTENABLECLR |= pin;
	}
}

void GPIO_WriteBit(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin, FunctionalState state)
{
	if (state == ENABLE)
  {
    GPIOx->DATAOUT |= pin;
  }
  else
  {
    GPIOx->DATAOUT &= ~pin;
  }
}

void GPIO_IntClear(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTCLEAR = (1 << Num);

//       return CMSDK_GPIO->INTSTATUS;
 }
 
void GPIO_SetIntEnable(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTENSET = (1 << Num);

//       return CMSDK_GPIO->INTENSET;
 }
 
void GPIO_ClrIntEnable(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTENCLR = (1 << Num);

//       return CMSDK_GPIO->INTENCLR;
 }
 
  void GPIO_SetIntHighLevel(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTTYPECLR = (1 << Num); /* Clear INT TYPE bit */
       CMSDK_GPIO->INTPOLSET = (1 << Num);  /* Set INT POLarity bit */
 }
 
  void GPIO_SetIntRisingEdge(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTTYPESET = (1 << Num); /* Set INT TYPE bit */
       CMSDK_GPIO->INTPOLSET = (1 << Num);  /* Set INT POLarity bit */
 }
 
  void GPIO_SetIntLowLevel(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTTYPECLR = (1 << Num);  /* Clear INT TYPE bit */
       CMSDK_GPIO->INTPOLCLR = (1 << Num);   /* Clear INT POLarity bit */
 }
 
  void GPIO_SetIntFallingEdge(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num)
 {
       CMSDK_GPIO->INTTYPESET = (1 << Num);  /* Set INT TYPE bit */
       CMSDK_GPIO->INTPOLCLR = (1 << Num);   /* Clear INT POLarity bit */
 }


