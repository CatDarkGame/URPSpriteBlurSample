Shader "CatDarkGame/Sprites/Sprite_Master"
{
    /* 
        Urp Lit ���̴��� ���� �ϳ��� ���̴����� �پ��� ����� ������ �� �ִ� Sprite Master ���̴�
        - Pass �ڵ� ���� hlsl ���� �и� �� Custom ShaderGUI ���� �� RenderType ���� ��� �߰��� ����
        - (����� ���� ���̴� �����Ҷ� �ʿ��� ���� �����)
    */

    Properties
    {
        [PerRendererData] 
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        // [HideInInspector] PixelSnap ("Pixel snap", Float) = 0 // ���� �ʿ��ϸ� UnityCG.cginc�� UnityPixelSnap �Լ� �̿��ؼ� ����
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
        Tags // GUI ��ũ��Ʈ���� ���� Ÿ�Կ� �°� �ڵ� ��ȯ
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
