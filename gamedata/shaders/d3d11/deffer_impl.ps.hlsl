#include "common.hlsli"
#include "sload.hlsli"

void main(p_bumped_new I, out IXrayGbufferPack O)
{
    IXrayMaterial M;
    M.Depth = I.position.z;

    M.Sun = I.tcdh.w;
    M.Hemi = I.tcdh.z;
    M.Point = I.position.xyz;

    M.Color = s_base.Sample(smp_base, I.tcdh.xy);

    float4 Lmap = s_lmap.Sample(smp_base, I.tcdh.xy);
    float4 Mask = s_mask.Sample(smp_base, I.tcdh.xy);
    Mask /= dot(Mask, 1.0f);

    float2 tcdbump = I.tcdh.xy * dt_params.xy;

    float3 Detail_R = s_dt_r.Sample(smp_base, tcdbump).xyz * Mask.x;
    float3 Detail_G = s_dt_g.Sample(smp_base, tcdbump).xyz * Mask.y;
    float3 Detail_B = s_dt_b.Sample(smp_base, tcdbump).xyz * Mask.z;
    float3 Detail_A = s_dt_a.Sample(smp_base, tcdbump).xyz * Mask.w;
    float3 Detail = Detail_R + Detail_G + Detail_B + Detail_A;

    float4 Normal_R = s_dn_r.Sample(smp_base, tcdbump) * Mask.x;
    float4 Normal_G = s_dn_g.Sample(smp_base, tcdbump) * Mask.y;
    float4 Normal_B = s_dn_b.Sample(smp_base, tcdbump) * Mask.z;
    float4 Normal_A = s_dn_a.Sample(smp_base, tcdbump) * Mask.w;

    float3 Normal = Normal_R.wzy + Normal_G.wzy + Normal_B.wzy + Normal_A.wzy - 0.5;
    Normal.z *= 0.5f;

    M.Roughness = min(1.0f, Normal_R.x + Normal_G.x + Normal_B.x + Normal_A.x);
    M.Color.xyz *= Detail * 2.0f;

    M.Metalness = 0.0f;
    M.SSS = 0.0f;
    M.AO = 1.0f;

    M.Normal = mul(float3x3(I.M1, I.M2, I.M3), Normal);
    M.Normal = normalize(M.Normal);

    M.Sun = Lmap.w;
    M.Hemi = M.Color.w;

#ifdef USE_LEGACY_LIGHT
    M.Metalness = L_material.w;
#else
    M.Roughness = 1.0f - M.Roughness * 0.9f;
#endif

    O.Velocity = I.hpos_curr.xy / I.hpos_curr.w - I.hpos_old.xy / I.hpos_old.w;
    GbufferPack(O, M);
}
