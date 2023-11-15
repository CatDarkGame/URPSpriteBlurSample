#ifndef CATDARKGAME_SPRITEMASTER_DEPTHONLY_PASS_INCLUDED
#define CATDARKGAME_SPRITEMASTER_DEPTHONLY_PASS_INCLUDED


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
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.color = input.color * _Color * _RendererColor;
    return output;
}

half4 frag(Varyings i) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if defined(_ALPHATEST_ON)
        half4 mainTex = i.color * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
        clip(mainTex.a - _Cutoff);
    #endif
   
    return 0;
}


#endif