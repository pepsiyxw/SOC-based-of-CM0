#include "CMSDK_CM0.h"
#include "simple_timer.h"
#include "Systick.h"
#include "Handcontroller.h"
#include "oled.h"
#include "flybird.h"
#include "seg.h"
#include "music.h"
#include "IMU.h"
#include "microphone.h"
#include "SG90.h"
#include "speech.h"

//手柄按键获取和角度获取放在定时器0中断
//系统控制以及鸟运动控制放在定时器1中断

extern u8 angle;	//声源定位所测得的角度

extern int PS2_KEY,PS2_LX,PS2_LY;

extern float roll,pitch,yaw;

void OLED_Showgyro(void);
void OLED_PS2(void);
void OLED_Angle(void);
void OLED_ShowScore(void);
void OLED_Angle_value(void);

int main()
{
	SimpleTimer_Init(sptimer0,50000*25,ENABLE);		//用于捕获按键值，摇杆值，角度值，位于flybird.c文件中
	SimpleTimer_Init(sptimer1,50000*25,ENABLE);		//用于进行手柄按键扫描，进行游戏系统控制，位于flybird.c文件中
	GameInit();		//第二关sobel边缘检测阈值的初始化
	IMU_init();		//陀螺仪的初始化，用于接收xyz姿态角，即初始化串口1
	OLED_Init();	//OLED显示屏的初始化
	PS2_Init();		
	PS2_SetInit();	//手柄初始化
	mp3_Init();		//音乐模块初始化，即初始化串口2
	SG90_Init();
	SetSG90(93000);	//第二关舵机初始化	93000 - 73000	18750 - 93750
	Speech_Init();	//语音控制模块初始化，即九个外部中断的初始化
	delay_ms(1000);	
	NVIC_EnableIRQ(SPTIMER0_IRQn);
	NVIC_EnableIRQ(SPTIMER1_IRQn);

	OLED_ShowString(1,1,"SCORE1:",12,1);
	OLED_ShowString(64,1,"SCORE3:",12,1);
	OLED_ShowString(1,30,"LX:",12,1);
	OLED_ShowString(64,30,"LY:",12,1);
	OLED_ShowString(1,45,"Ag:",12,1);
	while(1)
	{
		OLED_ShowScore();
		OLED_Showgyro();
		OLED_PS2();
		OLED_Angle();
		GameBgm();
		Custom2_Map_Control();
	}
}

void OLED_ShowScore()
{
	OLED_ShowNum(44,1,FlyBird->SCORE,2,12,1);
	OLED_ShowNum(107,1,FlyBird->CUSTOM3_SCORE,2,12,1);
}

void OLED_Showgyro()
{
		if(pitch > 0)
		{
			OLED_ShowString(1,15,"P:+",12,1);
			OLED_ShowNum(20,15,pitch,3,12,1);
		}
		else
		{
			OLED_ShowString(1,15,"P:-",12,1);
			OLED_ShowNum(20,15,-pitch,3,12,1);
		}
		if(roll > 0)
		{
			OLED_ShowString(64,15,"R:+",12,1);
			OLED_ShowNum(84,15,roll,3,12,1);
		}
		else
		{
			OLED_ShowString(64,15,"R:-",12,1);
			OLED_ShowNum(84,15,-roll,3,12,1);
		}
}

void OLED_PS2()
{
	OLED_ShowNum(20,30,PS2_LX,3,12,1);
	OLED_ShowNum(84,30,PS2_LY,3,12,1);
}

void OLED_Angle()
{
	OLED_ShowNum(20,45,angle,2,12,1);
}

void OLED_Angle_value()
{
	OLED_ShowNum(0,15,MICROPHONE->UPFIRST_CNT,5,12,1);
	OLED_ShowNum(64,15,MICROPHONE->DOWNFIRST_CNT,5,12,1);
	OLED_ShowNum(0,0,MICROPHONE->LEFTFIRST_CNT,5,12,1);
	OLED_ShowNum(64,0,MICROPHONE->RIGHTFIRST_CNT,5,12,1);
}
