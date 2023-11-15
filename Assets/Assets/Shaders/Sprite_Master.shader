Shader "CatDarkGame/Sprites/Sprite_Master"
{
    /* 
        Urp Lit 쉐이더와 같이 하나의 쉐이더에서 다양한 기능을 지원할 수 있는 Sprite Master 쉐이더
        - Pass 코드 별도 hlsl 파일 분리 및 Custom ShaderGUI 연동 및 RenderType 변경 기능 추가된 상태
        - (기능이 많은 쉐이더 개발할때 필요한 로직 참고용)
    */

    Properties
    {
        [PerRendererData] 
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        // [HideInInspector] PixelSnap ("Pixel snap", Float) = 0 // 추후 필요하면 UnityCG.cginc의 UnityPixelSnap 함수 이용해서 구현
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [HideInInspector] _AlphaTex ("External Alpha", 2D) = "white" {}
        [HideInInspector] _EnableExternalAlpha ("Enable External Alpha", Float) = 0

        _Surface("__surface", Float) = 0.0
        [ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
    }

    SubShader
    {
        Tags // GUI 스크립트에서 렌더 타입에 맞게 자동 변환
        {
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "UniversalMaterialType" = "Lit" 
            "IgnoreProjector" = "True" 
            "ShaderModel"="4.5"
        }

        Blend[_SrcBlend][_DstBlend]
        
        Pass 
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward"}

            ZWrite[_ZWrite]
            Cull Off

            HLSLPROGRAM
  
            #pragma target 4.5

            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma vertex vert
            #pragma fragment frag


            #include "HLSL/Input.hlsl"
            #include "HLSL/ForwardPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma target 4.5

            #pragma shader_feature_local_fragment _ALPHATEST_ON
           
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "HLSL/Input.hlsl"
            #include "HLSL/ShadowCasterPass.hlsl"
            ENDHLSL
        }


        Pass 
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Off

            HLSLPROGRAM
  
            #pragma target 4.5

            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            #pragma vertex vert
            #pragma fragment frag

  
            #include "HLSL/Input.hlsl"
            #include "HLSL/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }

    Fallback "Sprites/Default"
    CustomEditor "CatDarkGame.Editor.Sprite_Master_GUI"
}
