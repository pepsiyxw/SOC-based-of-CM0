#include "Key_Scan.h"
void Key_Init(void)
{
	GPIO_InitTypeDef Key_Pin;
	Key_Pin.GPIO_AltFun = GPIO_Pin_Null;
	Key_Pin.GPIO_IRQ = GPIO_IRQ_NULL;
	Key_Pin.GPIO_Pin = Key_Row0|Key_Row1|Key_Row2|Key_Row3;
	GPIO_Init(GPIOA,&Key_Pin);

}
u8 key_scan(void)
{
	u8 KeyValue=16;
	GPIO_ClrOutput(GPIOA,Key_Row0);
	GPIO_SetOutput(GPIOA,Key_Row1|Key_Row2|Key_Row3);
	if(((GPIOA->DATA )&0x0F00)!=0x0F00)	 //说明PD4-PD7状态发生变化，列检测
	{
		delay_ms(10);			//按键消抖
		if(((GPIOA->DATA )&0x0F00)!=0x0F00) 		//再次判断是否有按键按下
		{
			switch((GPIOA->DATA )&0xF000)//检测输入数据寄存器PB4-PB7对应位的电平状态
			{ 
				case 0xE000:KeyValue=0;break;//说明PB4接收到低电平，第一行第一列对应第一个按键
				case 0xD000:KeyValue=1;break; 
				case 0xB000:KeyValue=2;break;
				case 0x7000:KeyValue=3;break; 
				default:break;
			}

		 }	
	}
	GPIO_ClrOutput(GPIOA,Key_Row1);
	GPIO_SetOutput(GPIOA,Key_Row0|Key_Row2|Key_Row3);
	if(((GPIOA->DATA )&0x0F00)!=0x0F00)	 //说明PD4-PD7状态发生变化，列检测
	{
		delay_ms(10);			//按键消抖
		if(((GPIOA->DATA )&0x0F00)!=0x0F00) 		//再次判断是否有按键按下
		{
			switch((GPIOA->DATA )&0xF000)//检测输入数据寄存器PB4-PB7对应位的电平状态
			{ 
				case 0xE000:KeyValue=4;break;//说明PB4接收到低电平，第一行第一列对应第一个按键
				case 0xD000:KeyValue=5;break; 
				case 0xB000:KeyValue=6;break;
				case 0x7000:KeyValue=7;break; 
				default:break;
			}

		 }	
	}
	GPIO_ClrOutput(GPIOA,Key_Row2);
	GPIO_SetOutput(GPIOA,Key_Row1|Key_Row0|Key_Row3);
	if(((GPIOA->DATA )&0x0F00)!=0x0F00)	 //说明PD4-PD7状态发生变化，列检测
	{
		delay_ms(10);			//按键消抖
		if(((GPIOA->DATA )&0x0F00)!=0x0F00) 		//再次判断是否有按键按下
		{
			switch((GPIOA->DATA )&0xF000)//检测输入数据寄存器PB4-PB7对应位的电平状态
			{ 
				case 0xE000:KeyValue=8;break;//说明PB4接收到低电平，第一行第一列对应第一个按键
				case 0xD000:KeyValue=9;break; 
				case 0xB000:KeyValue=10;break;
				case 0x7000:KeyValue=11;break; 
				default:break;
			}

		 }	
	}
	GPIO_ClrOutput(GPIOA,Key_Row3);
	GPIO_SetOutput(GPIOA,Key_Row1|Key_Row2|Key_Row0);
	if(((GPIOA->DATA )&0x0F00)!=0x0F00)	 //说明PD4-PD7状态发生变化，列检测
	{
		delay_ms(10);			//按键消抖
		if(((GPIOA->DATA )&0x0F00)!=0x0F00) 		//再次判断是否有按键按下
		{
			switch((GPIOA->DATA )&0xF000)//检测输入数据寄存器PB4-PB7对应位的电平状态
			{ 
				case 0xE000:KeyValue=12;break;//说明PB4接收到低电平，第一行第一列对应第一个按键
				case 0xD000:KeyValue=13;break; 
				case 0xB000:KeyValue=14;break;
				case 0x7000:KeyValue=15;break; 
				default:break;
			}

		 }	
	}
	
	return KeyValue;
	
	
}


    


