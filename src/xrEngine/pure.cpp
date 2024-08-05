#include "stdafx.h"
#pragma hdrstop

#include "pure.h"

//ENGINE_API int	__cdecl	_REG_Compare(const void *e1, const void *e2)
//{
//	_REG_INFO *p1 = (_REG_INFO *)e1;
//	_REG_INFO *p2 = (_REG_INFO *)e2;
//	return (p2->Prio - p1->Prio);
//}

static xrCriticalSection PureGuard;
#define DECLARE_RP_SAFE(name) void  rp_##name(void *p) { xrCriticalSectionGuard guard(PureGuard); ((pure##name *)p)->On##name(); }

DECLARE_RP_SAFE(Frame);
DECLARE_RP_SAFE(Render);
DECLARE_RP_SAFE(AppActivate);
DECLARE_RP_SAFE(AppDeactivate);
DECLARE_RP_SAFE(AppStart);
DECLARE_RP_SAFE(DrawUI);
DECLARE_RP_SAFE(AppEnd);
DECLARE_RP_SAFE(DeviceReset);
DECLARE_RP_SAFE(ScreenResolutionChanged);


