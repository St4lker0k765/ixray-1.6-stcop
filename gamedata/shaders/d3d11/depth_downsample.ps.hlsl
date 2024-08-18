#include "common.hlsli"

struct PSInput
{
    float4 hpos : SV_Position;
    float4 texcoord : TEXCOORD0;
};

float main(PSInput I) : SV_Target
{
	return depth_unpack.x * rcp(s_position.SampleLevel(smp_nofilter, I.texcoord.xy, 0).x - depth_unpack.y);
}