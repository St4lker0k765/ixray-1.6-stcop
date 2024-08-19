#include "stdafx.h"

#include "r4_rendertarget.h"

void CRenderTarget::phase_combine_volumetric()
{
	u32 Offset = 0;
    constexpr u32 vertex_color = color_rgba(0, 0, 0, 255);

	RCache.set_ColorWriteEnable(D3DCOLORWRITEENABLE_RED|D3DCOLORWRITEENABLE_GREEN|D3DCOLORWRITEENABLE_BLUE);

	//Upsample volumetrics and blend them with framebuffer
    u_setrt(rt_Generic_0, nullptr, nullptr, nullptr);
    RCache.set_CullMode(CULL_NONE);
    RCache.set_Stencil(FALSE);

	FVF::TL* pv = (FVF::TL*)RCache.Vertex.Lock(3, g_combine->vb_stride, Offset);
	pv->set(-1.0, 1.0, 1.0, 1.0, vertex_color, 0.0, 0.0);
	pv++;
	pv->set(3.0, 1.0, 1.0, 1.0, vertex_color, 2.0, 0.0);
	pv++;
	pv->set(-1.0, -3.0, 1.0, 1.0, vertex_color, 0.0, 2.0);
	pv++;
	RCache.Vertex.Unlock(3, g_combine->vb_stride);

	//Go go power rangers
    RCache.set_Element(s_combine_volumetric->E[0]);
	RCache.set_c("upsampling_params", RCache.get_width() * 0.5, RCache.get_height() * 0.5, 2.0 / RCache.get_width(), 2.0 / RCache.get_height());
	RCache.set_Geometry(g_combine);
	RCache.Render(D3DPT_TRIANGLELIST, Offset, 0, 3, 0, 1);

	//Restore
	RCache.set_ColorWriteEnable();
}