#include "cm0_timer.h"

 void Timer_EnableIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
       CMSDK_TIMER->CTRL |= CMSDK_TIMER_CTRL_IRQEN_Msk;
 }

 void Timer_DisableIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
		CMSDK_TIMER->CTRL &= ~CMSDK_TIMER_CTRL_IRQEN_Msk;
 }
  void Timer_StartTimer(CMSDK_TIMER_TypeDef *CMSDK_TIMER,uint32_t irq_en)
 {
       if (irq_en!=0)                                                                          /* non zero - enable IRQ */
         CMSDK_TIMER->CTRL = (CMSDK_TIMER_CTRL_IRQEN_Msk | CMSDK_TIMER_CTRL_EN_Msk);
       else{                                                                                   /* zero - do not enable IRQ */
         CMSDK_TIMER->CTRL = ( CMSDK_TIMER_CTRL_EN_Msk);                                       /* enable timer */
        }
 }
  void Timer_StopTimer(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
       CMSDK_TIMER->CTRL &= ~CMSDK_TIMER_CTRL_EN_Msk;
 }
 
 uint32_t Timer_GetValue(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
       return CMSDK_TIMER->VALUE;
 }
  void Timer_SetValue(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t value)
 {
       CMSDK_TIMER->VALUE = value;
 }
  uint32_t Timer_GetReload(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
       return CMSDK_TIMER->RELOAD;
 }
 
 void Timer_SetReload(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t value)
 {
       CMSDK_TIMER->RELOAD = value;
 }
  void Timer_ClearIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
       CMSDK_TIMER->INTCLEAR = CMSDK_TIMER_INTCLEAR_Msk;
 }
  uint32_t  Timer_StatusIRQ(CMSDK_TIMER_TypeDef *CMSDK_TIMER)
 {
       return CMSDK_TIMER->INTSTATUS;
 }
   void Timer_Init_IntClock(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t reload,
 uint32_t irq_en)
 {
       CMSDK_TIMER->CTRL = 0;
       CMSDK_TIMER->VALUE = reload;
       CMSDK_TIMER->RELOAD = reload;
       if (irq_en!=0)                                                                          /* non zero - enable IRQ */
         CMSDK_TIMER->CTRL = (CMSDK_TIMER_CTRL_IRQEN_Msk | CMSDK_TIMER_CTRL_EN_Msk);
       else{                                                                                   /* zero - do not enable IRQ */
         CMSDK_TIMER->CTRL = ( CMSDK_TIMER_CTRL_EN_Msk);                                       /* enable timer */
        }
 }
  void Timer_Init_ExtClock(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t reload,uint32_t irq_en)
 {
       CMSDK_TIMER->CTRL = 0;
       CMSDK_TIMER->VALUE = reload;
       CMSDK_TIMER->RELOAD = reload;
       if (irq_en!=0)                                                                                  /* non zero - enable IRQ */
            CMSDK_TIMER->CTRL = (CMSDK_TIMER_CTRL_IRQEN_Msk |
                                   CMSDK_TIMER_CTRL_SELEXTCLK_Msk |CMSDK_TIMER_CTRL_EN_Msk);
       else  {                                                                                         /* zero - do not enable IRQ */
            CMSDK_TIMER->CTRL = ( CMSDK_TIMER_CTRL_EN_Msk |
                                    CMSDK_TIMER_CTRL_SELEXTCLK_Msk);                                   /* enable timer */
         }
 }
  void Timer_Init_ExtEnable(CMSDK_TIMER_TypeDef *CMSDK_TIMER, uint32_t reload,uint32_t irq_en)
 {
       CMSDK_TIMER->CTRL = 0;
       CMSDK_TIMER->VALUE = reload;
       CMSDK_TIMER->RELOAD = reload;
       if (irq_en!=0)                                                                                  /* non zero - enable IRQ */
            CMSDK_TIMER->CTRL = (CMSDK_TIMER_CTRL_IRQEN_Msk |
                                   CMSDK_TIMER_CTRL_SELEXTEN_Msk | CMSDK_TIMER_CTRL_EN_Msk);
       else  {                                                                                         /* zero - do not enable IRQ */
            CMSDK_TIMER->CTRL = ( CMSDK_TIMER_CTRL_EN_Msk |
                                    CMSDK_TIMER_CTRL_SELEXTEN_Msk);                                    /* enable timer */
         }
 }



