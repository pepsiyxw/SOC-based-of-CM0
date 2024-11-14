#include "interrupt.h"

void LED_Init()
{
	GPIO_InitTypeDef LED_Pin;
	LED_Pin.GPIO_AltFun = GPIO_Pin_Null;
	LED_Pin.GPIO_IRQ = GPIO_IRQ_NULL;
	LED_Pin.GPIO_Pin = GPIO_Pin_7;
	GPIO_Init(GPIOA,&LED_Pin);
}

