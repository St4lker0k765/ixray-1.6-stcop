#include "common.hlsli"

// Vertex
v2p_TL main(v_TL I)
{
    v2p_TL O;

    O.HPos = mul(m_VP, I.P);
    O.Tex0 = I.Tex0;
    O.Color = I.Color.bgra; //	swizzle vertex colour

    O.HPos.xy += m_taa_jitter.xy * O.HPos.w;

    return O;
}
