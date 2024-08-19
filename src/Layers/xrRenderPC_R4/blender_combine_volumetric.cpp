#include "stdafx.h"
#include "blender_combine_volumetric.h"

CBlender_combine_volumetric::CBlender_combine_volumetric() { description.CLS = 0; }
CBlender_combine_volumetric::~CBlender_combine_volumetric() {}

void CBlender_combine_volumetric::Compile(CBlender_Compile& C)
{
    IBlender::Compile(C);

    switch (C.iElement)
    {
    case 0:
	    C.r_Pass("stub_fullscreen_triangle", "volumetric_upsample", false, FALSE, FALSE, TRUE, D3DBLEND_ONE, D3DBLEND_ONE);
        C.r_dx10Texture("s_position", r2_RT_P);
		C.r_dx10Texture("t_lowres_input", "$user$volumetric_0");
        C.r_dx10Texture("t_lowres_depth", r2_RT_half_depth);

        C.r_dx10Sampler("smp_rtlinear");
        C.r_dx10Sampler("smp_nofilter");
        C.r_End();
        break;
    }
}