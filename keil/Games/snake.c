#include "snake.h"
#include "oled.h"
#include "cm0_Timer.h"
#include "cm0_uart.h"
#include "cm0_gpio.h"
#include "Key_Scan.h"

u8 o = 0;
extern u8 left = 0xff;
extern u8 right = 0xff;
extern u8 up = 0xff;
extern u8 down = 0xff;
u8 moveflag=0,foodflag=0,giveup=0,fun=0;
u8 yanshi=60,mode=0,point=1;
u16 count=0;
u32 time;


extern u8 head = 3,tail = 0,page = 0,start = 0;
struct snake Pos[20]; //�ߵ������������ݣ�
struct snake food ;//ʳ�������λ�ã
 
 
void SnakeGame_Init(void)
{
	Timer_Init_IntClock(Timer0,50000*4,1);
	Timer_Init_IntClock(Timer1,50000,1);
	Timer_StopTimer(Timer0);
	OLED_Init();
	NVIC->ISER[0] = 0xffff;
}

void Game_Process(void)
{
		OLED_Refresh();
		while(page==0)
		{
		page0();
		}	
		while(page==1)
		{
		if(start==1)
			{
			OLED_Clear();
			Timer_StartTimer(Timer0,1);
			head=3;
			Snake_Init();
			start=0;
			} 
		Food_Init();
		keypros();
		}
		while(page==2)
		{
			Timer_StopTimer(Timer0);
			
			Snake_Over();
		}

}

void delay(u32 i)
{
  while(i--);
}
void ShowTen()
{
  OLED_ShowChar(0,3,'T',16,1);
}
 
void  Game_Restart()
{
   if(left==0)
   delay(10);
   if(left==0)
   {
      page=0;
	  OLED_Clear();
   }
   while(!left);
}
 
 
void Snake_Over()//������������������֮����ʾgame over,ͬʱ���ϼ�⸴ԭ���Ƿ񱻰���;
{
   if(page==2)
   {
      mode=0;//�������㣬����ͻ�����һ����Ϸ��ʼʱ����ߵ����ƶ���
      Timer_StopTimer(Timer0);
      OLED_Clear();//��������
      while(page==2)
	  {
	     OLED_ShowString(0,0,"game over",8,1);
		 OLED_ShowString(0,30,"press left to restart",8,1);
         Game_Restart();
	  }
   }
}
 
 
 
void Food_Init()	//ʳ���ʼ��������
{
   	u8 i;
	while(!foodflag)
	{
	  food.x=count%128;
	  food.y=count%64;
	  for(i=0;i<head;i++)
	  {
	    if((food.x==Pos[i].x&&food.y==Pos[i].y)||food.x>=15||food.y>=7||food.x<=1||food.y<=1)//һ������������������ʳ��
		//���ݾ�Ӧ�ñ���������Ϊ����������ڵ�ͼ�ϣ�
		giveup=1;
	  }
	  if(giveup==1)  
	  {
	   foodflag=0;
	   giveup=0;
	  }
	  else
	  {
	  foodflag=1;
	  OLED_SnakeBody(food.x,food.y);
	  giveup=0;
	  break;
	  }
	}
}
 
void Snake_Init()		 //�߳�ʼ��������
{
u8 i;
   Pos[0].x=6;
   Pos[0].y=3;
   Pos[1].x=7;
   Pos[1].y=3;
   Pos[2].x=8;
   Pos[2].y=3;
   for(i=0;i<head;i++)
   {
     OLED_SnakeBody(Pos[i].x,Pos[i].y);
   }
}
 
 
 
 void leftkey()
 {
    if(left==0&&mode!=1&&mode!=2)
	delay(10);
	if(left==0&&mode!=1&&mode!=2)
	     mode=1;
    while(!left);
 }
 void rightkey()
 {
   if(right==0&&mode!=1&&mode!=2)
   delay(10);
   if(right==0&&mode!=1&&mode!=2)
        mode=2;
	while(!right);
 }
 void upkey()
 {
   if(up==0&&mode!=3&&mode!=4)
   delay(10);
   if(up==0&&mode!=3&&mode!=4)
     mode=3;
	 while(!up);
 }
 void downkey()
 {
   if(down==0&&mode!=3&&mode!=4)
   delay(10);
   if(down==0&&mode!=3&&mode!=4)
      mode=4;
	  while(!down) ;
 }
 
void  keypros()
{
    leftkey();
	rightkey();
	upkey();
	downkey();
}
 
 
 
void modeleft()
{
   u8 i,j;
   if(mode==1)
   {
      //�����ж��Ƿ�ײǽ��
	  if(Pos[head-1].x==0)
	  page=2;
	  //���ж��Ƿ�ҧ���Լ������壻
	  if(page==1)
	      for(i=0;i<head-1;i++)	//����Ҫע�⣬ǧ��Ҫ��ͷ������Ҳ����ȥ��ʡһ��ʱ�䣻
		  {
		      if((Pos[head-1].x-1)==Pos[i].x&&Pos[head-1].y==Pos[i].y)
			                                                      page=2;
		  }
		  //�����û��ײǽҲû��ҧ���Լ�  ���ǾͿ��ǳԵ�ʳ���û�гԵ��������
      if(page==1)
	  {
	  //�Ե�ʳ��������
	    if((Pos[head-1].x-1)==food.x&&Pos[head-1].y==food.y)
		{
		  head++;//���ȼ�һ��
		  foodflag=0;//ˢ����һ��ʳ�
		  Pos[head-1].x=Pos[head-2].x-1;   //�ı�ͷ��֮�󣬰�֮ǰͷ����λ������֮����и�ֵ��
		  Pos[head-1].y=Pos[head-2].y;
		  OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����µĹ�ͷ���������ˣ�
		}
		else	 //û�Ե�ʳ��������
		{
		  
		   OLED_CLR_Body(Pos[tail].x,Pos[tail].y);//���Ͼ�β�ͣ�
		   for(j=0;j<head-1;j++)
		   {
		     Pos[j].x=Pos[j+1].x;
			 Pos[j].y=Pos[j+1].y;
		   }
		    Pos[head-1].x--;
		   OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����¹�ͷ�������ȵ�����ͷ����Ȼ��������ݶ�ʧ��
		}
	  }
 
   }
}
void moderight()
{
   u8 i,j;
   if(mode==2)
   {
      //�����ж��Ƿ�ײǽ��
	  if(Pos[head-1].x==15)
	  page=2;
	  //���ж��Ƿ�ҧ���Լ������壻
	  if(page==1)
	      for(i=0;i<head-1;i++)	//����Ҫע�⣬ǧ��Ҫ��ͷ������Ҳ����ȥ��ʡһ��ʱ�䣻
		  {
		      if((Pos[head-1].x+1)==Pos[i].x&&Pos[head-1].y==Pos[i].y)
			  page=2;
		  }
	  //�����û��ײǽҲû��ҧ���Լ�  ���ǾͿ��ǳԵ�ʳ���û�гԵ��������
      if(page==1)
	  {
	  //�Ե�ʳ��������
	    if((Pos[head-1].x+1)==food.x&&Pos[head-1].y==food.y)
		{
		  head++;//���ȼ�һ��
		  foodflag=0;//ˢ����һ��ʳ�
		  Pos[head-1].x=Pos[head-2].x+1;   //�ı�ͷ��֮�󣬰�֮ǰͷ����λ������֮����и�ֵ��
		  Pos[head-1].y=Pos[head-2].y;
		  OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����µĹ�ͷ���������ˣ�
		}
		else	 //û�Ե�ʳ��������
		{
		  
		   OLED_CLR_Body(Pos[tail].x,Pos[tail].y);//���Ͼ�β�ͣ�
		   for(j=0;j<head-1;j++)
		   {
		     Pos[j].x=Pos[j+1].x;
			 Pos[j].y=Pos[j+1].y;
		   }
		    Pos[head-1].x++;
		   OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����¹�ͷ�������ȵ�����ͷ����Ȼ��������ݶ�ʧ��
		}
	  }
 
   }
}
void modeup()
{
   u8 i,j;
   if(mode==3)
   {
      //�����ж��Ƿ�ײǽ��
	  if(Pos[head-1].y==0)
	  page=2;
	  //���ж��Ƿ�ҧ���Լ������壻
	  if(page==1)
	      for(i=0;i<head-1;i++)	//����Ҫע�⣬ǧ��Ҫ��ͷ������Ҳ����ȥ��ʡһ��ʱ�䣻
		  {
		      if((Pos[head-1].x)==Pos[i].x&&Pos[head-1].y-1==Pos[i].y)
			                                                      page=2;
		  }
		  //�����û��ײǽҲû��ҧ���Լ�  ���ǾͿ��ǳԵ�ʳ���û�гԵ��������
      if(page==1)
	  {
	  //�Ե�ʳ��������
	    if(Pos[head-1].x==food.x&&(Pos[head-1].y-1)==food.y)
		{
		  head++;//���ȼ�һ��
		  foodflag=0;//ˢ����һ��ʳ�
		  Pos[head-1].x=Pos[head-2].x;   //�ı�ͷ��֮�󣬰�֮ǰͷ����λ������֮��ֵ����ͷ����
		  Pos[head-1].y=Pos[head-2].y-1;
		  OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����µĹ�ͷ���������ˣ�
		}
		else	 //û�Ե�ʳ��������
		{
		  
		   OLED_CLR_Body(Pos[tail].x,Pos[tail].y);//���Ͼ�β�ͣ�
		   for(j=0;j<head-1;j++)
		   {
		     Pos[j].x=Pos[j+1].x;
			 Pos[j].y=Pos[j+1].y;
		   }
		    Pos[head-1].y--;
		   OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����¹�ͷ�������ȵ�����ͷ����Ȼ��������ݶ�ʧ��
		}
	  }
 
   }
}
void modedown()
{
   u8 i,j;
   if(mode==4)
   {
      //�����ж��Ƿ�ײǽ��
	  if(Pos[head-1].y==7)
	  page=2;
	  //���ж��Ƿ�ҧ���Լ������壻
	  if(page==1)
	      for(i=0;i<head-1;i++)	//����Ҫע�⣬ǧ��Ҫ��ͷ������Ҳ����ȥ��ʡһ��ʱ�䣻
		  {
		      if((Pos[head-1].x)==Pos[i].x&&Pos[head-1].y+1==Pos[i].y)
			                                                      page=2;
		  }
		  //�����û��ײǽҲû��ҧ���Լ�  ���ǾͿ��ǳԵ�ʳ���û�гԵ��������
      if(page==1)
	  {
	  //�Ե�ʳ��������
	    if(Pos[head-1].x==food.x&&(Pos[head-1].y+1)==food.y)
		{
		  head++;//���ȼ�һ��
		  foodflag=0;//ˢ����һ��ʳ�
		  Pos[head-1].x=Pos[head-2].x;   //�ı�ͷ��֮�󣬰�֮ǰͷ����λ������֮��ֵ����ͷ����
		  Pos[head-1].y=Pos[head-2].y+1;
		  OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����µĹ�ͷ���������ˣ�
		}
		else	 //û�Ե�ʳ��������
		{
		  
		   OLED_CLR_Body(Pos[tail].x,Pos[tail].y);//���Ͼ�β�ͣ�
		   for(j=0;j<head-1;j++)
		   {
		     Pos[j].x=Pos[j+1].x;
			 Pos[j].y=Pos[j+1].y;
		   }
		    Pos[head-1].y++;
		   OLED_SnakeBody(Pos[head-1].x,Pos[head-1].y);//�����¹�ͷ�������ȵ�����ͷ����Ȼ��������ݶ�ʧ��
		}
	  }
 
   }
}
void choice()
{
   if(left==0)
   {
   delay(10);
   if(left==0)
  {
   point++;
   if(point>3)
   point=1;
  }	 
  while(!left);
  }
 
  if(right==0)
  {
   delay(10);
   if(right==0)
   {
     
	 if(point==1)
	 {
	    time=128;
		page=1;
		OLED_Clear();
		OLED_ShowString(30,20,"Speed:Fast",16,1);
		delay(50000*250);
	    start=1;
		foodflag=0;
	 }
		if(point==2)
		{
		time=256;
		page=1;
		OLED_Clear();
		OLED_ShowString(30,20,"Speed:Slow",16,1);
		delay(50000*250);
	    start=1;
		foodflag=0;
	    }
		if(point==3)
		fun=1;
   }
    while(!right);
  }
}  
 
void modepros()
{
  modeup();
  modeleft();
  modedown();
  moderight();
}
void page0()
{
 OLED_ShowString(10,0,"greedy snake",8,1);
 OLED_ShowString(20,10,"difficult",8,1);
 OLED_ShowString(20,20,"normal",8,1);
 OLED_ShowString(20,30,"easy",8,1) ;
if(point==1)
{
  OLED_ShowChar(10,10,'>',8,1);
  OLED_ShowChar(10,20,' ',8,1);
  OLED_ShowChar(10,30,' ',8,1);
}
if(point==2)
{
  OLED_ShowChar(10,10,' ',8,1);
  OLED_ShowChar(10,20,'>',8,1);
  OLED_ShowChar(10,30,' ',8,1);
}
if(point==3)
{
  OLED_ShowChar(10,10,' ',8,1);
  OLED_ShowChar(10,20,' ',8,1);
  OLED_ShowChar(10,30,'>',8,1);
}
if(fun==1)
{
   OLED_Clear();
  OLED_ShowString(0,4,"you really have face",12,1);
  delay(50000*500);
  OLED_Clear();
  fun=0;
}
choice();
} 


//void TIMER0Handler()
//{
//	count++;
//	if(count==time)
//     {
//         count=0;
//	     modepros();
//	 }
//	 Timer_ClearIRQ(Timer0);
//}

//void TIMER1Handler()
//{
//	if(o>1)
//	{
//		o = 0;
//	}
//	if(o == 0)
//		{GPIO_ClrOutput(GPIOA,Key_Row0);
//		if(Key_Col0 == 0)
//		{
//			right = 0;
//		}
//		else if(Key_Col1 == 0)
//		{
//			down = 0;
//		}
//		else if(Key_Col2 == 0)
//		{
//			left = 0;
//		}
//		else
//		{
//			right = 1;
//			down = 1;
//			left = 1;
//		}
//		GPIO_SetOutput(GPIOA,Key_Row0);
//	}
//	else if(o == 1)
//	{
//		GPIO_ClrOutput(GPIOA,Key_Row1);
//		if(Key_Col1 == 0)
//		{
//			up = 0;
//		}
//		else
//		{
//			up = 1;
//		}
//		GPIO_SetOutput(GPIOA,Key_Row1);
//	}
//	o++;
//	Timer_ClearIRQ(Timer1);
//}

