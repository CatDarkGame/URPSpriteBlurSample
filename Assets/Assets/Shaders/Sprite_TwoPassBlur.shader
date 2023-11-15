Shader "CatDarkGame/Sprites/Sprite_TwoPassBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _BlendAmount("Blur Amount", Range(0,1)) = 0.5

        [Header(Blur Quality)] [Space(5)]
        _BlurOffset("Blur Offset", Range(1, 9)) = 2
        _MipLevel("Mip Level", Range(0, 5)) = 2
	}
	
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
        struct Attributes
        {
            float3 positionOS   : POSITION;
            float4 color        : COLOR;
            float2 uv           : TEXCOORD0;
        };

        struct Varyings
        {
            float4  positionCS      : SV_POSITION;
            float4  color           : COLOR;
            float2  uv              : TEXCOORD0;
            float4  screenPosition  : TEXCOORD1;
        };

        TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
        float4 _MainTex_ST;
        float2 _MainTex_TexelSize;
        
        TEXTURE2D(_CustomCameraTexture); SAMPLER(sampler_CustomCameraTexture);
        float2 _CustomCameraTexture_TexelSize;

        half _BlendAmount;
        half _BlurOffset;
        half _MipLevel;

        Varyings vert(Attributes attributes)
        {
            Varyings o = (Varyings)0;
               
            o.positionCS = TransformObjectToHClip(attributes.positionOS);
            o.screenPosition = ComputeScreenPos(o.positionCS);	
            o.uv = attributes.uv;
            o.color = attributes.color;
            return o;
        }
    
        half4 TwoPassFragment_1 (Varyings i) : SV_TARGET 
        {
            float2 uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
            half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv); 

            half mipLevel = _MipLevel * _BlendAmount;
            half4 col = 0.0f; 
        	const float offsets[] = {
        		-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0
        	};
        	const float weights[] = {
        		0.01621622, 0.05405405, 0.12162162, 0.19459459, 0.22702703,
        		0.19459459, 0.12162162, 0.05405405, 0.01621622
        	};
        	for (int j = 0; j < 9; j++) {
        		float offset = offsets[j] * _BlurOffset * _MainTex_TexelSize.x;
        		// col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(offset, 0.0f)) * weights[j];
                col += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(offset, 0.0f), _MipLevel) * weights[j];  // mipmap을 활용해 부족한 블러 느낌 강화
        	}
        	half4 finalColor = lerp(baseMap, col, _BlendAmount);

        	return finalColor;
        }
        
        half4 TwoPassFragment_2 (Varyings i) : SV_TARGET 
        {
            half4 copyPassCol = 0.0f; 
        	float2 copyPassUV = i.screenPosition.xy / i.screenPosition.w;
        	const float offsets[] = {
        		-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0
        	}; 
        	const float weights[] = {
        		0.01621622, 0.05405405, 0.12162162, 0.19459459, 0.22702703,
        		0.19459459, 0.12162162, 0.05405405, 0.01621622
        	};
        	for (int j = 0; j < 9; j++) 
        	{
        		float offset = offsets[j] * _BlurOffset  * _CustomCameraTexture_TexelSize.y;
                copyPassCol += SAMPLE_TEXTURE2D(_CustomCameraTexture, sampler_CustomCameraTexture, copyPassUV + float2(0.0, offset)) * weights[j];
        	}

            half4 finalColor = copyPassCol;
            finalColor.a = _BlendAmount;
        	return finalColor;
        }
    
    ENDHLSL
        
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
        ZWrite Off 
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha	

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Name "TwoPass_1"
            HLSLPROGRAM

                #pragma vertex vert
                #pragma fragment TwoPassFragment_1

            ENDHLSL
        }
        
        Pass
        {
            Tags { "LightMode" = "Forward_TwoPass" }
            Name "TwoPass_2"
            HLSLPROGRAM

                #pragma vertex vert
                #pragma fragment TwoPassFragment_2

            ENDHLSL
        }
    }
}