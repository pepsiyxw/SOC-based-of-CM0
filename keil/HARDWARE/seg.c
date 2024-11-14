#include "seg.h"

void Seg_ENABLE()
{
	SEG->SEG_EN = 1;
}

void Seg_DISABLE()
{
	SEG->SEG_EN = 0;
}

void Seg_DrawData(u16 data)
{
	SEG->DATA = data;
}
