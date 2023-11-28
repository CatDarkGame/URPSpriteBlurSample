#ifndef CATDARKGAME_SPRITEMASTER_UNLIT_FORWARD_PASS_INCLUDED
#define CATDARKGAME_SPRITEMASTER_UNLIT_FORWARD_PASS_INCLUDED


struct Attributes
{
    float3 positionOS   : POSITION;
    half4 color        : COLOR;
    float2 uv           : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4  positionCS      : SV_POSITION;
    half4  color           : COLOR;
    float2  uv              : TEXCOORD0;
    #if defined(DEBUG_DISPLAY)
        float3  positionWS      : TEXCOORD2;
    #endif
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionCS = TransformObjectToHClip(input.positionOS);
    #if defined(DEBUG_DISPLAY)
    output.positionWS = TransformObjectToWorld(input.positionOS);
    #endif
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.color = input.color * _Color * _RendererColor;
    return output;
}

half4 frag(Varyings i) : SV_Target
{
    half4 mainTex = i.color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    #if defined(_ALPHATEST_ON)
        clip(mainTex.a - _Cutoff);
    #endif


    #if defined(DEBUG_DISPLAY)
    SurfaceData2D surfaceData;
    InputData2D inputData;
    half4 debugColor = 0;

    InitializeSurfaceData(mainTex.rgb, mainTex.a, surfaceData);
    InitializeInputData(i.uv, inputData);
    SETUP_DEBUG_DATA_2D(inputData, i.positionWS);

    if(CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
    {
        return debugColor;
    }

    #endif

    return mainTex;
}


#endif