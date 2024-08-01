#include "common.hlsli"
#include "sload.hlsli"

#include "metalic_roughness_light.hlsli"
#include "metalic_roughness_ambient.hlsli"

uniform float3 L_sun_dir_e;

void main(p_bumped_new I, out f_forward O)
{
    IXrayMaterial M;
    M.Depth = I.position.z;

    M.Sun = I.tcdh.w;
    M.Hemi = I.tcdh.z;
    M.Point = I.position.xyz;

    SloadNew(I, M);

#ifdef USE_AREF
    #ifdef USE_DXT1_HACK
    M.Color.xyz *= rcp(max(0.0001f, M.Color.w));
    #endif
#endif

    M.Normal = mul(float3x3(I.M1, I.M2, I.M3), M.Normal);
    M.Normal = normalize(M.Normal);

#ifdef USE_LM_HEMI
    float4 lm = s_hemi.Sample(smp_rtlinear, I.tcdh.zw);

    M.Sun = get_sun(lm);
    M.Hemi = get_hemi(lm);
#endif

    M.Sun = saturate(M.Sun * 2.0f);
    M.Color.xyz = saturate(M.Color.xyz);

#ifdef USE_LEGACY_LIGHT
    #ifndef USE_PBR
    M.Metalness = L_material.w;
    #else
    M.Color.xyz *= M.AO;
    M.AO = 1.0f;
    float Specular = M.Metalness * dot(M.Color.xyz, LUMINANCE_VECTOR);
    M.Color.xyz = lerp(M.Color.xyz, F0, M.Metalness);
    M.Metalness = 0.5f - M.Roughness * M.Roughness * 0.5f;
    M.Roughness = Specular;
    #endif
#endif

    float3 Light = M.Sun * DirectLight(float4(L_sun_color, 0.5f), L_sun_dir_e.xyz, M.Normal, M.Point.xyz, M.Color.xyz, M.Metalness, M.Roughness);
    float3 Ambient = AmbientLighting(M.Point, M.Normal, M.Color.xyz, M.Metalness, M.Roughness, M.Hemi);
    O.Color.xyz = Ambient + Light.xyz;
    O.Color.w = M.Color.w;

    float fog = saturate(length(M.Point) * fog_params.w + fog_params.x);
    O.Color.xyz = lerp(O.Color.xyz, fog_color.xyz, fog);
    O.Color.w *= 1.0f - fog * fog;

    O.Velocity = I.hpos_curr.xy / I.hpos_curr.w - I.hpos_old.xy / I.hpos_old.w;
    O.Reactive = O.Color.w * 0.9f;
}
