#include "common.hlsli"

struct v2p
{
    float2 tc0 : TEXCOORD0; // lmap
    float2 tc1 : TEXCOORD1; // lmap
    float3 c0 : COLOR0; // hemi
};

// Pixel
float4 main(v2p I) : COLOR
{
    float4 t_base = tex2D(s_base, I.tc0);
    float4 t_lmap = tex2D(s_lmap, I.tc1);

    // lighting
    float3 l_base = t_lmap.rgb; // base light-map
    float3 l_hemi = I.c0 * t_base.a; // hemi is implicitly inside texture
    float l_sun = t_lmap.a; // sun color
    float3 light = L_ambient + l_base + l_hemi;
    return float4(light, l_sun);
}
