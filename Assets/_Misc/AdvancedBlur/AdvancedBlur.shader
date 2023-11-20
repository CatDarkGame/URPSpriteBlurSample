Shader "CatDarkGame/Sprites/AdvancedBlur"
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

            //return baseMap;

        /*    float2 offset = 3.0 * _MainTex_TexelSize;
            half4 o = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-offset.x, 0)) / 4.0h;
            o += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(offset.x, 0)) / 4.0h;
            o += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(0, -offset.y)) / 4.0h;
            o += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(0, offset.y)) / 4.0h; */

            half samplingCount = 16.0;
            half mip = 0;
            float2 offset = 2.0 * _MainTex_TexelSize;
            half4 o = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(-offset.x, 0), mip) / samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(offset.x, 0), mip) / samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, -offset.y), mip) / samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, offset.y), mip) / samplingCount;

            mip = 1;
            offset = 3.0 * _MainTex_TexelSize;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(-offset.x, 0), mip) / samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(offset.x, 0), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, -offset.y), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, offset.y), mip) /  samplingCount;

            mip = 2;
            offset = 5.0 * _MainTex_TexelSize;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(-offset.x, 0), mip) / samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(offset.x, 0), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, -offset.y), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, offset.y), mip) /  samplingCount;

            mip = 4;
            offset = 8.0 * _MainTex_TexelSize;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(-offset.x, 0), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(offset.x, 0), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, -offset.y), mip) /  samplingCount;
            o += SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv + float2(0, offset.y), mip) /  samplingCount;

            return o;

        }




            float GaussianWeight(int x, int y)
            {
                // 가우시안 분포에 기반한 가중치 계산
                // (여기서는 간단한 예시로 가중치 값을 정적으로 설정합니다. 실제로는 정규분포 공식에 따라 계산해야 합니다.)
                float sigma = 1.0;
                float norm = 1.0 / (2.0 * 3.141592 * sigma * sigma);
                float expPart = exp(-((x * x + y * y) / (2.0 * sigma * sigma)));
                return norm * expPart;
            }
        
        half4 TwoPassFragment_2 (Varyings i) : SV_TARGET 
        {




            float2 uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
            half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv); 

            half4 copyPassCol = 0.0f; 
        	float2 copyPassUV = i.screenPosition.xy / i.screenPosition.w;


             for (int x = -4; x <= 4; x++)
                {
                    for (int y = -4; y <= 4; y++)
                    {
                        float weight = GaussianWeight(x, y);
                   //     sum += tex2D(_MainTex, uv + float2(x, y) * offset) * weight;
                        copyPassCol += SAMPLE_TEXTURE2D(_CustomCameraTexture, sampler_CustomCameraTexture, copyPassUV + (float2(x, y)*1.5) * _MainTex_TexelSize) * weight;
                    }
                }

       

           half4 copyPassCol2 = SAMPLE_TEXTURE2D(_CustomCameraTexture, sampler_CustomCameraTexture, copyPassUV);
           //return float4(copyPassCol2.rgb,1);
           // return lerp(baseMap, copyPassCol2, _BlendAmount);



           return lerp(baseMap, float4(copyPassCol.rgb,1), _BlendAmount);




        	const float offsets[] = {
        		-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0
        	}; 
        	const float weights[] = {
        		0.01621622, 0.05405405, 0.12162162, 0.19459459, 0.22702703,
        		0.19459459, 0.12162162, 0.05405405, 0.01621622
        	};

            int samples = 9;//(2 * 9) + 1;
            int index = 0;
            for(int x=0; x<samples; x++)
            {
                for(int y=0; y<samples; y++)
                {
                    float2 offset = 0;
                    int indexOffset = x;
                    offset.x = offsets[indexOffset] * _BlurOffset  * _MainTex_TexelSize.x;
                    offset.y = offsets[indexOffset] * _BlurOffset  * _MainTex_TexelSize.y;
                    copyPassCol += SAMPLE_TEXTURE2D(_CustomCameraTexture, sampler_CustomCameraTexture, copyPassUV + offset) ;//* weights[index%9];
                    index++;
                   
                
                //     float2 offset = float2(x - 9, y - 9);
                   // copyPassCol += SAMPLE_TEXTURE2D(_CustomCameraTexture, sampler_CustomCameraTexture, copyPassUV + (offset * _CustomCameraTexture_TexelSize));// * weights[index%9];
                  
                }
            }
            half4 finalColor = lerp(baseMap, copyPassCol/81, _BlendAmount);
            finalColor.a=1;
             return finalColor;

        	/*for (int j = 0; j < 9; j++) 
        	{
        		float offset = offsets[j] * _BlurOffset  * _CustomCameraTexture_TexelSize.y;
                copyPassCol += SAMPLE_TEXTURE2D(_CustomCameraTexture, sampler_CustomCameraTexture, copyPassUV + float2(0.0, offset)) * weights[j];
        	}*/



          //  half4 finalColor = copyPassCol;
           // finalColor.a = _BlendAmount;
        	//return finalColor;
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