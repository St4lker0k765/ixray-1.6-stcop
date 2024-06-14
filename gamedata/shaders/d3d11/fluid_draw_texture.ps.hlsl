#include "fluid_common.hlsli"

//	Pixel
float4 main_ps_4_0(p_fluidsim input) : SV_Target
{
    if (textureNumber == 1)
    {
        return abs(Texture_color.SampleLevel(samLinear, input.texcoords, 0)).xxxx;
    }
    else if (textureNumber == 2)
    {
        return abs(Texture_velocity0.SampleLevel(samLinear, input.texcoords, 0));
    }
    else
    {
        return float4(abs(Texture_obstvelocity.SampleLevel(samLinear, input.texcoords, 0).xy),
            abs(Texture_obstacles.SampleLevel(samLinear, input.texcoords, 0).r), 1);
    }
}
