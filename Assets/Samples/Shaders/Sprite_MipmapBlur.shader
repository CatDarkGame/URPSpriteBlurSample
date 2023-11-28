Shader "CatDarkGame/Sprites/Sprite_MipmapBlur"
{
    /* 
        Sprite-Unlit-Default 쉐이더 기반, Mipmap Blending 기능 추가한 쉐이더
        - Mipmap Level을 낮추는 방식으로 블러 표현하는 방식
        - Sprite 리소스의 Generate Mipmap 옵션 활성화가 필요
        - 연산 비용은 크지 않지만 그림체에 따라서 잘 안 어울리는 단점이 있음
        - TODO : 일부 변수를 Material PropertyBlock으로 제어되게 개선해야함
    */
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}

        _BlendAmount("Blend Amount", Range(0,1)) = 0.5
        _MipLevel("Mip Level", Range(0, 5)) = 2
        

        // Legacy properties. They're here so that materials using this shader can gracefully fallback to the legacy sprite shader.
        [HideInInspector] _Color ("Tint", Color) = (1,1,1,1)
        [HideInInspector] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [HideInInspector] _AlphaTex ("External Alpha", 2D) = "white" {}
        [HideInInspector] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off

        Pass
        {
            Tags { "LightMode" = "UniversalForward" "Queue"="Transparent" "RenderType"="Transparent"}

            HLSLPROGRAM

            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex UnlitVertex
            #pragma fragment UnlitFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #if defined(DEBUG_DISPLAY)
                #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/InputData2D.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"
            #endif

           
            struct Attributes
            {
                float3 positionOS   : POSITION;
                float4 color        : COLOR;
                float2 uv           : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4  positionCS      : SV_POSITION;
                float4  color           : COLOR;
                float2  uv              : TEXCOORD0;
                #if defined(DEBUG_DISPLAY)
                float3  positionWS      : TEXCOORD2;
                #endif
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            
            float4 _Color;
            half4 _RendererColor;

            half _MipLevel;
            half _BlendAmount;

            Varyings UnlitVertex(Attributes attributes)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(attributes);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.positionCS = TransformObjectToHClip(attributes.positionOS);
                #if defined(DEBUG_DISPLAY)
                    o.positionWS = TransformObjectToWorld(attributes.positionOS);
                #endif
                o.uv = TRANSFORM_TEX(attributes.uv, _MainTex);
                o.color = attributes.color * _Color * _RendererColor;
                return o;
            }


            float4 UnlitFragment(Varyings i) : SV_Target
            {
                float2 uv = i.uv;
                float4 mainTexMipmap = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv, _MipLevel);
                float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

                float4 result = 1;
                half smoothAmount = smoothstep(0.0, 1, _BlendAmount); // _BlendAmount;
                result = lerp(mainTex, mainTexMipmap, smoothAmount) * i.color;
                
                #if defined(DEBUG_DISPLAY)
                    SurfaceData2D surfaceData;
                    InputData2D inputData;
                    half4 debugColor = 0;

                    InitializeSurfaceData(result.rgb, result.a, surfaceData);
                    InitializeInputData(i.uv, inputData);
                    SETUP_DEBUG_DATA_2D(inputData, i.positionWS);

                    if(CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
                    {
                        return debugColor;
                    }
                #endif

                return result;
            }
            ENDHLSL
        }
    }

    Fallback "Sprites/Default"
}
