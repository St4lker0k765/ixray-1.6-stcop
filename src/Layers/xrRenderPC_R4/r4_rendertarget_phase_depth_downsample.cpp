#include "stdafx.h"

#include "r4_rendertarget.h"

void CRenderTarget::phase_depth_downsample()
{
	u32 Offset = 0;
    constexpr u32 vertex_color = color_rgba(0, 0, 0, 255);

	//Set the viewport
	D3D_VIEWPORT viewport[1] = { 0, 0, 0, 0, 0.f, 1.f };	
	viewport[0].Width = RCache.get_width() * 0.5f;
	viewport[0].Height = RCache.get_height() * 0.5f;
	RContext->RSSetViewports(1, viewport);

	//Render the AO and view-z into new rendertarget
    u_setrt(rt_half_depth, nullptr, nullptr, nullptr);
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
    RCache.set_Element(s_depth_downsample->E[0]);
	RCache.set_Geometry(g_combine);
	RCache.Render(D3DPT_TRIANGLELIST, Offset, 0, 3, 0, 1);
	
	//Restore the viewport
	viewport[0].Width = RCache.get_width();
	viewport[0].Height = RCache.get_height();
	RContext->RSSetViewports(1, viewport);
}