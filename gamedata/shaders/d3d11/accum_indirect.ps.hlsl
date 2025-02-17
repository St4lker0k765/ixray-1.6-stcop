#include "common.hlsli"
#include "lmodel.hlsli"

// Pixel
// Note: this is a float-sphere
uniform float3 direction;

float4 main(float4 tc : TEXCOORD0, float4 pos2d : SV_Position) : SV_Target
{
    //  float4 _P		= tex2Dproj 	(s_position, 	tc);
    //  float4 _N		= tex2Dproj 	(s_normal,   	tc);
    float2 tcProj = tc.xy / tc.w;

    gbuffer_data gbd = gbuffer_load_data(GLD_P(tcProj, pos2d, ISAMPLE));

    // float4	_P				= s_position.Sample( smp_nofilter, tcProj );
    // float4	_N				= s_normal.Sample( smp_nofilter, tcProj );
    float4 _P = float4(gbd.P, gbd.mtl);
    float4 _N = float4(gbd.N, gbd.hemi);

    float3 L2P = _P.xyz - Ldynamic_pos.xyz; // light2point
    float3 L2P_N = normalize(L2P); // light2point
    float rsqr = dot(L2P, L2P); // distance 2 light (squared)
    float att = saturate(1 - rsqr * Ldynamic_pos.w); // q-linear attenuate
    float light = saturate(dot(-L2P_N, _N.xyz));
    float hemi = saturate(dot(L2P_N, direction));

    // Final color
    return blendp(float4(Ldynamic_color.xyz * att * light * hemi, 0), tc);
}
