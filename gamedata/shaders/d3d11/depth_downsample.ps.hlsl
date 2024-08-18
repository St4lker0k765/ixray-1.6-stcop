#include "common.hlsli"

struct PSInput
{
    float4 hpos : SV_Position;
    float4 texcoord : TEXCOORD0;
};

float4 main(PSInput I) : SV_Target
{
	float4 Depth;

#ifndef SM_5
    Depth.x = s_position.SampleLevel(smp_nofilter, I.texcoord.xy, int2(1, 0), 0).x;
    Depth.y = s_position.SampleLevel(smp_nofilter, I.texcoord.xy, int2(1, 1), 0).x;
    Depth.z = s_position.SampleLevel(smp_nofilter, I.texcoord.xy, int2(0, 1), 0).x;
    Depth.w = s_position.SampleLevel(smp_nofilter, I.texcoord.xy, int2(0, 0), 0).x;
#else // !SM_5
    Depth = s_position.GatherRed(smp_nofilter, I.texcoord.xy);
#endif // SM_5

    Depth = depth_unpack.x * rcp(Depth - depth_unpack.y);
	return min(min(Depth.x, Depth.y), min(Depth.z, Depth.w));
}