#include "common.hlsli"

struct v2p
{
    float2 tc0 : TEXCOORD0;
    float4 c : COLOR0;

//	Igor: for additional depth dest
#ifdef USE_SOFT_PARTICLES
    float4 tctexgen : TEXCOORD1;
#endif //	USE_SOFT_PARTICLES

    float4 hpos : SV_Position;
    float fog : FOG;
};

// Pixel
float4 main(v2p I) : SV_Target
{
    float4 result = I.c * s_base.Sample(smp_base, I.tc0);
    result.xyz *= L_hemi_color.xyz + L_ambient.xyz;

    //	Igor: additional depth test
#ifdef USE_SOFT_PARTICLES
    float2 tcProj = I.tctexgen.xy / I.tctexgen.w;
    gbuffer_data gbd = gbuffer_load_data(tcProj, I.hpos);
    float4 _P = float4(gbd.P, gbd.mtl);
    float spaceDepth = _P.z - I.tctexgen.z;
    result.a *= Contrast(saturate(spaceDepth * 1.3h), 2);
    result.rgb *= Contrast(saturate(spaceDepth * 1.3h), 2);
#endif //	USE_SOFT_PARTICLES

    clip(result.a - (0.01f / 255.0f));

    result.w *= I.fog;
    return result;
}
