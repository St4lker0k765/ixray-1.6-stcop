#include "stdafx.h"
#include "blender_depth_downsample.h"

CBlender_depth_downsample::CBlender_depth_downsample() { description.CLS = 0; }
CBlender_depth_downsample::~CBlender_depth_downsample() {}

void CBlender_depth_downsample::Compile(CBlender_Compile& C)
{
    IBlender::Compile(C);

	C.r_Pass("stub_fullscreen_triangle", "depth_downsample", FALSE, FALSE, FALSE);
	C.r_dx10Texture("s_position", r2_RT_P);
	C.r_dx10Sampler("smp_nofilter");
	C.r_End();
}