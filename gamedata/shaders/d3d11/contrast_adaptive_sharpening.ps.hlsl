// This is really short version of CAS based on AMD presentation (https://gpuopen.com/wp-content/uploads/2019/07/FidelityFX-CAS.pptx)
#include "common.hlsli"

float sharpening_intensity;

float4 main(float2 texcoord : TEXCOORD0, float4 hpos : SV_Position) : SV_Target
{
    // Cross-pattern neighborhood, we could use .Load but w/e.
    float3 top_smp = s_image.SampleLevel(smp_rtlinear, texcoord, 0.0, int2(0, -1)).xyz;
    float3 left_smp = s_image.SampleLevel(smp_rtlinear, texcoord, 0.0, int2(-1, 0)).xyz;
    float3 center_smp = s_image.SampleLevel(smp_rtlinear, texcoord, 0.0).xyz;
    float3 right_smp = s_image.SampleLevel(smp_rtlinear, texcoord, 0.0, int2(1, 0)).xyz;
    float3 down_smp = s_image.SampleLevel(smp_rtlinear, texcoord, 0.0, int2(0, 1)).xyz;

    // Min and max luma, from green channel
    float min_luma = min(top_smp.y, min(left_smp.y, min(center_smp.y, min(right_smp.y, down_smp.y))));
    float max_luma = max(top_smp.y, max(left_smp.y, max(center_smp.y, max(right_smp.y, down_smp.y))));

    // Temp
    float d_min_luma = min_luma;
    float d_max_luma = 1.0 - max_luma;

    // Calculate base strength of sharpening (A from presentation)
    float sharpening_amount = d_max_luma < d_min_luma ? d_max_luma / max_luma : d_min_luma / max_luma;

    // Filter weight
    float3 weight = sqrt(sharpening_amount) * lerp(-0.05, -0.2, sharpening_intensity); // Min is set to -0.05, to give a wider range of sharpening.

    // Window
    float3 window = top_smp + left_smp + right_smp + down_smp;

    // Filter the samples and weight them
    return float4((weight * window + center_smp) * rcp(1.0 + weight * 4.0), 1.0);
}
