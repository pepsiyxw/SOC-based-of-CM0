#ifndef __HANDCONTROLLER_H
#define __HANDCONTROLLER_H

#include "CMSDK_CM0.h"                  // Device header
#include "cm0_gpio.h"
#include "Systick.h"

#define DI   ((GPIOB->DATA)>>8)%2        //PA0  ����

#define DO_H GPIO_SetOutput(GPIOB,DO_Pin)        //����λ��
#define DO_L GPIO_ClrOutput(GPIOB,DO_Pin)        //����λ��

#define CS_H GPIO_SetOutput(GPIOB,CS_Pin)       //CS����
#define CS_L GPIO_ClrOutput(GPIOB,CS_Pin)       //CS����

#define CLK_H GPIO_SetOutput(GPIOB,CLK_Pin)       //ʱ������
#define CLK_L GPIO_ClrOutput(GPIOB,CLK_Pin)      //ʱ������

#define	CLK_Pin		GPIO_Pin_11
#define	CS_Pin		GPIO_Pin_10
#define	DO_Pin		GPIO_Pin_9
#define	DI_Pin		GPIO_Pin_8

//These are our button constants
#define PSB_SELECT      1
#define PSB_L3          2
#define PSB_R3          3
#define PSB_START       4
#define PSB_PAD_UP      5
#define PSB_PAD_RIGHT   6
#define PSB_PAD_DOWN    7
#define PSB_PAD_LEFT    8
#define PSB_L2          9
#define PSB_R2          10
#define PSB_L1          11
#define PSB_R1          12
#define PSB_GREEN       13
#define PSB_RED         14
#define PSB_BLUE        15
#define PSB_PINK        16

#define PSB_TRIANGLE    13
#define PSB_CIRCLE      14
#define PSB_CROSS       15
#define PSB_SQUARE      16

#define PSS_RX 5                //��ҡ��X������
#define PSS_RY 6
#define PSS_LX 7
#define PSS_LY 8

//Myself
#define KEY_START       4
#define KEY_UP      	5
#define KEY_RIGHT   	6
#define KEY_DOWN    	7
#define KEY_LEFT    	8
#define KEY_LEFT2		9
#define KEY_RIGHT2		10
#define KEY_LEFT1		11
#define KEY_RIGHT1		12
#define KEY_W       	13
#define KEY_D         	14
#define KEY_S        	15
#define KEY_A        	16

#define KEY_PAUSE		13
#define KEY_OK			14
#define KEY_CANCLE		16

extern u8 Data[9];
extern u16 MASK[16];
extern u16 Handkey;

void PS2_Init(void);
u8 PS2_RedLight(void);   //�ж��Ƿ�Ϊ���ģʽ
void PS2_ReadData(void); //���ֱ�����
void PS2_Cmd(u8 CMD);		  //���ֱ���������
u8 PS2_DataKey(void);		  //����ֵ��ȡ
u8 PS2_AnologData(u8 button); //�õ�һ��ҡ�˵�ģ����
void PS2_ClearData(void);	  //������ݻ�����
void PS2_Vibration(u8 motor1, u8 motor2);//������motor1  0xFF���������أ�motor2  0x40~0xFF

void PS2_EnterConfing(void);	 //��������
void PS2_TurnOnAnalogMode(void); //����ģ����
void PS2_VibrationMode(void);    //������
void PS2_ExitConfing(void);	     //�������
void PS2_SetInit(void);		     //���ó�ʼ��

#endif
