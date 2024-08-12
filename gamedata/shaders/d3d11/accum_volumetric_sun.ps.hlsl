#include "common.hlsli"

#undef USE_ULTRA_SHADOWS

#define RAY_PATH 2.0h
#define JITTER_TEXTURE_SIZE 64.0f

#define JITTER_SUN_SHAFTS

#ifdef SUN_SHAFTS_QUALITY
    #if SUN_SHAFTS_QUALITY == 1
        // #define FILTER_LOW
        #define RAY_SAMPLES 20
    #elif SUN_SHAFTS_QUALITY == 2
        // #define FILTER_LOW
        #define RAY_SAMPLES 20
    #elif SUN_SHAFTS_QUALITY == 3
        // #define FILTER_LOW
        #define RAY_SAMPLES 40
    #endif
#endif

#include "shadow.hlsli"

float4 sun_shafts_intensity;

struct PSInput
{
    float4 hpos : SV_Position;
    float4 texcoord : TEXCOORD0;
};

float4 main(PSInput I) : SV_Target
{
#ifndef SUN_SHAFTS_QUALITY
    return float4(0, 0, 0, 0);
#else //	SUN_SHAFTS_QUALITY
    IXrayGbuffer O;
    GbufferUnpack(I.texcoord.xy, I.hpos, O);

    float3 P = O.Point;

#ifndef JITTER_SUN_SHAFTS
	//	Fixed ray length, fixed step dencity
	//	float3	direction = (RAY_PATH/RAY_SAMPLES)*normalize(P);
	//	Variable ray length, variable step dencity
	float3 direction = P / RAY_SAMPLES;
#else //	JITTER_SUN_SHAFTS
	//	Variable ray length, variable step dencity, use jittering
	float4 J0 = jitter0[uint2(I.hpos.xy) % 64];
	float coeff = (RAY_SAMPLES - J0.x) / (RAY_SAMPLES * RAY_SAMPLES);
	float3 direction = P * coeff;
#endif //	JITTER_SUN_SHAFTS

    float depth = P.z;
    float deltaDepth = direction.z;

    float4 current = mul(m_shadow, float4(P, 1.0f));
    float4 delta = mul(m_shadow, float4(direction, 0.0f));

    float res = 0.0f;
    float max_density = sun_shafts_intensity;
    float density = max_density / RAY_SAMPLES;

    if(O.Depth > 0.9999f) {
		depth = 0.0f;
        res = max_density;
    }

    [unroll] for(int i = 0; i < RAY_SAMPLES; ++i)
    {
        if (depth > 0.3)
        {
		#ifndef FILTER_LOW
			res += density * shadow(current);
		#else
			res += density * sample_hw_pcf(current, float4(0, 0, 0, 0));
		#endif
        }

        depth -= deltaDepth;
        current -= delta;
    }

    float fSturation = dot(normalize(P), -Ldynamic_dir.xyz);

    //	Normalize dot product to
    fSturation = 0.4f * fSturation + 0.6f;

    float fog = saturate(length(P.xyz) * fog_params.w + fog_params.x);
    res = lerp(res, max_density, fog);
    res *= fSturation;

    return res * Ldynamic_color;
#endif // SUN_SHAFTS_QUALITY
}