#ifndef CATDARKGAME_SPRITEMASTER_INPUT_INCLUDED
#define CATDARKGAME_SPRITEMASTER_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#if defined(DEBUG_DISPLAY)
    #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/InputData2D.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"
#endif


TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
float4 _MainTex_ST;

float4 _Color;
half4 _RendererColor;
#if defined(_ALPHATEST_ON)
    half _Cutoff;
#endif



#endif