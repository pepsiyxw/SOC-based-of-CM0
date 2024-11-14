#include "IMU.h"

u8 RollL=0,RollH=0,PitchL=0,PitchH=0,YawL=0,YawH=0;
float roll,pitch,yaw;

void IMU_init(void)
{  	 
	UART_Init(UART1,115200,0,1);
	UART_IRQInit(UART1 ,0,1);
	NVIC_EnableIRQ(UARTRX1_IRQn);
}

void Bird2_Control(void)
{
		if(GetGameState() == custom2_scene || GetGameState() == custom3_scene)
		{
			if(pitch > 10)
			{
				Bird2Up_Disable();
				Bird2Down();
				if(pitch > pitch_level)
				{
					FlyBird->BIRD2_SPEED = high_speed;
				}
				else
				{
					FlyBird->BIRD2_SPEED = middle_speed;
				}

			}
			else if(pitch < -10)
			{
				Bird2Down_Disable();
				Bird2Up();
				if(pitch < -pitch_level)
				{
					FlyBird->BIRD2_SPEED = high_speed;
				}
				else
				{
					FlyBird->BIRD2_SPEED = middle_speed;
				}
			}
			else
			{
				FlyBird->BIRD2UP = 0;
				FlyBird->BIRD2DOWN = 0;
			}
			
			if(roll > 10)
			{
				Bird2Left_Disable();
				Bird2Right();
				if(roll > roll_level)
				{
					FlyBird->BIRD2_SPEED = high_speed;
				}
				else
				{
					FlyBird->BIRD2_SPEED = middle_speed;
				}
			}
			else if(roll < -10)
			{
				Bird2Right_Disable();
				Bird2Left();
				if(roll < -roll_level)
				{
					FlyBird->BIRD2_SPEED = high_speed;
				}
				else
				{
					FlyBird->BIRD2_SPEED = middle_speed;
				}
			}
			else
			{
				FlyBird->BIRD2LEFT = 0;
				FlyBird->BIRD2RIGHT = 0;
			}
		}
}

void UARTRX1Handler(void)
{	
	u8 com_data; 
	u8 i;
	static u8 RxCounter1=0;
	static u16 RxBuffer1[11]={0};
	static u8 RxState = 0;	
	static u8 RxFlag1 = 0;
	if(1) 
	{	  	
		UART_ClearRxIRQ(UART1);   
			com_data = UART_ReceiveByte(UART1);			
				if(RxState==0&&com_data==0x55)  
				{
					RxState=1;
					RxBuffer1[RxCounter1++]=com_data;
				}		
				else if(RxState==1&&com_data==0x55)  
				{
					RxState=2;
					RxBuffer1[RxCounter1++]=com_data;
				}
				else if(RxState==2&&com_data==0x01)  
				{
					RxState=3;
					RxBuffer1[RxCounter1++]=com_data;
				}
				else if(RxState==3&&com_data==0x06)  
				{
					RxState=4;
					RxBuffer1[RxCounter1++]=com_data;
				}
				else if(RxState==4)
				{
					RxBuffer1[RxCounter1++]=com_data;

					if(RxCounter1>=11)       
					{
						RxState=5;
						RxFlag1=1;
						RollL =RxBuffer1[4];
						RollH =RxBuffer1[5];
						PitchL=RxBuffer1[6];
						PitchH=RxBuffer1[7];
						YawL  =RxBuffer1[8];
						YawH  =RxBuffer1[9];
						
					}
				}
		
				else if(RxState==5)		
				{
						if(RxCounter1>=11 )
						{							
							if(RxFlag1)
							{
								//processing data
								roll = (float)((int16_t)(RollH << 8) | 0x00)/ 32768 * 180;
								pitch = (float)((int16_t)(PitchH << 8) | 0x00) / 32768 * 180;
								yaw = (float)((int16_t)(YawH << 8) | 0x00) / 32768 * 180;
							}
							RxFlag1 = 0;
							RxCounter1 = 0;
							RxState = 0;
						}
						else   
						{
							RxState = 0;
							RxCounter1=0;
							for(i=0;i<10;i++)
							{
								RxBuffer1[i]=0x00;      
							}
						}
				} 	
				else   
				{
						RxState = 0;
						RxCounter1=0;
						for(i=0;i<10;i++)
						{
							RxBuffer1[i]=0x00;      
						}
				}
	}  											 
} 



