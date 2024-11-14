#ifndef _CM0_GPIO_H
#define _CM0_GPIO_H

#include "CMSDK_CM0.h"

typedef struct {
	uint32_t GPIO_Pin;
	uint32_t GPIO_AltFun;
	uint32_t GPIO_IRQ;
}GPIO_InitTypeDef;

#define GPIOA                      CMSDK_GPIO0
#define GPIOB                      CMSDK_GPIO1
#define GPIOC                      CMSDK_GPIO2

#define GPIO_Pin_Null			   	((uint32_t)0x0000)  /* Pin Null selected */
#define GPIO_Pin_0                 	((uint32_t)0x0001)  /* Pin 0 selected */
#define GPIO_Pin_1                 	((uint32_t)0x0002)  /* Pin 1 selected */
#define GPIO_Pin_2                 	((uint32_t)0x0004)  /* Pin 2 selected */
#define GPIO_Pin_3                 	((uint32_t)0x0008)  /* Pin 3 selected */
#define GPIO_Pin_4                 	((uint32_t)0x0010)  /* Pin 4 selected */
#define GPIO_Pin_5                 	((uint32_t)0x0020)  /* Pin 5 selected */
#define GPIO_Pin_6                 	((uint32_t)0x0040)  /* Pin 6 selected */
#define GPIO_Pin_7                 	((uint32_t)0x0080)  /* Pin 7 selected */
#define GPIO_Pin_8                 	((uint32_t)0x0100)  /* Pin 8 selected */
#define GPIO_Pin_9                 	((uint32_t)0x0200)  /* Pin 9 selected */
#define GPIO_Pin_10                	((uint32_t)0x0400)  /* Pin 10 selected */
#define GPIO_Pin_11                	((uint32_t)0x0800)  /* Pin 11 selected */
#define GPIO_Pin_12                	((uint32_t)0x1000)  /* Pin 12 selected */
#define GPIO_Pin_13                	((uint32_t)0x2000)  /* Pin 13 selected */
#define GPIO_Pin_14                	((uint32_t)0x4000)  /* Pin 14 selected */
#define GPIO_Pin_15                	((uint32_t)0x8000)  /* Pin 15 selected */
#define GPIO_Pin_All               	((uint32_t)0xFFFF)  /* All pins selected */

//GPIOA IRQ
#define GPIO_IRQ_NULL              ((uint32_t)0x0000)
#define GPIO_IRQ_HighLevel         ((uint32_t)0x0001)
#define GPIO_IRQ_LowLevel          ((uint32_t)0x0002)
#define GPIO_IRQ_RisingEdge        ((uint32_t)0x0003)
#define GPIO_IRQ_FallingEdge       ((uint32_t)0x0004)

void GPIO_Init(CMSDK_GPIO_TypeDef * GPIOx, GPIO_InitTypeDef *pGPIO);
void GPIO_SetOutput(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin);
void GPIO_ClrOutput(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin);
void GPIO_SetOutputEnable(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin, FunctionalState state);
void GPIO_SetAltFun(CMSDK_GPIO_TypeDef * GPIOx, uint32_t op);
void GPIO_ClrAltFun(CMSDK_GPIO_TypeDef * GPIOx, uint32_t op);
void GPIO_WriteBit(CMSDK_GPIO_TypeDef * GPIOx, uint32_t pin, FunctionalState state);
void GPIO_IntClear(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);
void GPIO_SetIntEnable(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);
void GPIO_ClrIntEnable(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);
void GPIO_SetIntHighLevel(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);
void GPIO_SetIntRisingEdge(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);
void GPIO_SetIntLowLevel(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);
void GPIO_SetIntFallingEdge(CMSDK_GPIO_TypeDef *CMSDK_GPIO, uint32_t Num);

#endif
