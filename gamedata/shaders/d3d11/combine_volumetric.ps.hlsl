#include "common.hlsli"

Texture2D s_vollight;

struct PSInput
{
    float4 hpos : SV_Position;
    float4 texcoord : TEXCOORD0;
};

float4 main(PSInput I) : SV_Target
{
    return s_vollight[uint2(I.hpos.xy)];
}