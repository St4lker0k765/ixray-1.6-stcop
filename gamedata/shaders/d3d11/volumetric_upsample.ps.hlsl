/*
        Bilateral upsampling

        Author:
        - LVutner

        The shader upsamples low resolution volumetric buffer, and blends it with the framebuffer

        ---IX-Ray Engine---
*/

#include "common.hlsli"

Texture2D<float3> t_lowres_input;
Texture2D<float> t_lowres_depth;

float4 upsampling_params;

struct PSInput
{
    float4 hpos : SV_Position;
    float4 texcoord : TEXCOORD0;
};

float4 main(PSInput I) : SV_Target
{
	//Pixel coordinates
	float2 pixel_coords = I.texcoord * upsampling_params.xy - 0.5; //Remove half-pixel offset
    float2 o_pixel_coords = floor(pixel_coords);
	
	//Texture coordinates used for Gather
    float2 gather_texcoord = (o_pixel_coords + 1.0) * upsampling_params.zw;

	//Fetch depths
	float full_res_viewz = depth_unpack.x * rcp(s_position.SampleLevel(smp_nofilter, I.texcoord, 0).x - depth_unpack.y);
	float4 low_res_viewz = t_lowres_depth.GatherRed(smp_nofilter, I.texcoord);

	//Fetch low resolution color
	float4 low_res_r = t_lowres_input.GatherRed(smp_nofilter, gather_texcoord);
	float4 low_res_g = t_lowres_input.GatherGreen(smp_nofilter, gather_texcoord);
	float4 low_res_b = t_lowres_input.GatherBlue(smp_nofilter, gather_texcoord);

	//Bilinear weights
	float2 f = pixel_coords - o_pixel_coords;
	float w_00 = (1.0f - f.x) * (1.0f - f.y);
	float w_10 = f.x * (1.0f - f.y);
	float w_01 = (1.0f - f.x) * f.y;
	float w_11 = f.x * f.y;

	//Apply depth weight
	float4 bilat_weights = float4(w_01, w_11, w_10, w_00) * rcp(abs(full_res_viewz.xxxx - low_res_viewz) + 1e-4);

	//Final weighted color
	float3 color = float3(dot(low_res_r, bilat_weights), dot(low_res_g, bilat_weights), dot(low_res_b, bilat_weights)) * rcp(dot(bilat_weights, 1.0));

	//Output. This is going to be blended onto main framebuffer
	return float4(color.xyz, 0.0);
}