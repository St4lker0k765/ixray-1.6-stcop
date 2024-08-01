#include "common.hlsli"
#include "shared\wmark.hlsli"

struct vf
{
    float2 tc0 : TEXCOORD0;
    float3 c0 : COLOR0; // c0=all lighting
    float fog : FOG;
    float4 hpos : SV_Position;
};

vf main(v_static v)
{
    vf o;

    float3 N = unpack_normal(v.Nh.xyz);
    float4 P = wmark_shift(v.P, N);
    o.hpos = mul(m_VP, P);
    o.tc0 = unpack_tc_base(v.tc, v.T.w, v.B.w);
    o.c0 = 0;
    o.fog = 1.0f - calc_fogging(v.P);
    o.hpos.xy += m_taa_jitter.xy * o.hpos.w;

    return o;
}
