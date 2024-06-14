#include "common.hlsli"

#undef USE_ULTRA_SHADOWS

#define RAY_PATH 2.0h
#define JITTER_TEXTURE_SIZE 64.0f

#define JITTER_SUN_SHAFTS

#ifdef SUN_SHAFTS_QUALITY
    #if SUN_SHAFTS_QUALITY == 1
        #define FILTER_LOW
        #define RAY_SAMPLES 20
    #elif SUN_SHAFTS_QUALITY == 2
        #define FILTER_LOW
        #define RAY_SAMPLES 20
    #elif SUN_SHAFTS_QUALITY == 3
        #define FILTER_LOW
        #define RAY_SAMPLES 40
    #endif
#endif

#include "shadow.hlsli"

float4 volume_range; //	x - near plane, y - far plane
float4 sun_shafts_intensity;
uniform float4 screen_res;

float4 main(v2p_TL2uv I) : SV_Target
{
    float2 tc = I.Tex0.xy;
    float4 pos2d = I.HPos;

    gbuffer_data gbd = gbuffer_load_data(GLD_P(tc, pos2d, ISAMPLE));

#ifndef SUN_SHAFTS_QUALITY
    return float4(0, 0, 0, 0);
#else //	SUN_SHAFTS_QUALITY

    // float3	P = tex2D(s_position, tc).xyz;
    float3 P = gbd.P;

    #ifndef JITTER_SUN_SHAFTS
    //	Fixed ray length, fixed step dencity
    //	float3	direction = (RAY_PATH/RAY_SAMPLES)*normalize(P);
    //	Variable ray length, variable step dencity
    float3 direction = P / RAY_SAMPLES;
    #else //	JITTER_SUN_SHAFTS
    //	float2	tcJ = I.tcJ;
    //	Variable ray length, variable step dencity, use jittering
    // float4	J0 	= tex2D		(jitter0,tcJ);
    float4 J0 = jitter0.Sample(smp_jitter, tc * screen_res.x * 1.f / JITTER_TEXTURE_SIZE);
    float coeff = (RAY_SAMPLES - 1 * J0.x) / (RAY_SAMPLES * RAY_SAMPLES);
    float3 direction = P * coeff;
    //	float3	direction = P/(RAY_SAMPLES+(J0.x*4-2));
    #endif //	JITTER_SUN_SHAFTS

    float depth = P.z;
    float deltaDepth = direction.z;

    float4 current = mul(m_shadow, float4(P, 1));
    float4 delta = mul(m_shadow, float4(direction, 0));

    float res = 0;
    float max_density = sun_shafts_intensity;
    float density = max_density / RAY_SAMPLES;

    if (depth < 0.0001)
    {
        res = max_density;
    }

    [unroll] for (int i = 0; i < RAY_SAMPLES; ++i)
    {
        if (depth > 0.3)
        {
    #ifndef FILTER_LOW
            res += density * shadow(current);
    #else //	FILTER_LOW
            res += density * sample_hw_pcf(current, float4(0, 0, 0, 0));
    #endif //	FILTER_LOW
        }

        depth -= deltaDepth;
        current -= delta;
    }

    float fSturation = dot(normalize(P), -Ldynamic_dir.xyz);

    //	Normalize dot product to
    fSturation = 0.5f * fSturation + 0.5f;
    //	Map saturation to 0.2..1
    fSturation = 0.80f * fSturation + 0.20f;

    float fog = saturate(length(P.xyz) * fog_params.w + fog_params.x);
    float skyblend = fog * fog;

    res = lerp(res, max_density, skyblend);
    res *= fSturation;

    return res * Ldynamic_color;
#endif //	SUN_SHAFTS_QUALITY
}
