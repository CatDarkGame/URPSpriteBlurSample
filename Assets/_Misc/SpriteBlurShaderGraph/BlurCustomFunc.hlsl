
//UNITY_SHADER_NO_UPGRADE
#ifndef MYHLSLINCLUDE_INCLUDED
#define MYHLSLINCLUDE_INCLUDED

void SumBlur_float(UnityTexture2D Tex, float2 Uv0, float Power, out float3 Color, out float Alpha)
{
    Power *= 0.005;
    #define GETPIXEL(offsetx, offsety, gaussian) SAMPLE_TEXTURE2D(Tex.tex, Tex.samplerstate, Uv0 + float2(offsetx * Power, offsety * Power)) * gaussian
    
    // °¡¿îµ¥.
    float4 col = GETPIXEL(0, 0, 0.1592);
    
    // 1Ä­.
    col += GETPIXEL(-1, 0, 0.0965);
    col += GETPIXEL(1, 0, 0.0965);
    col += GETPIXEL(0, 1, 0.0965);
    col += GETPIXEL(0, -1, 0.0965);
    
    // 2Ä­.
    col += GETPIXEL(1, -1, 0.0585);
    col += GETPIXEL(1, 1, 0.0585);
    col += GETPIXEL(-1, 1, 0.0585);
    col += GETPIXEL(-1, -1, 0.0585);
    col += GETPIXEL(-2, 0, 0.0215);
    col += GETPIXEL(-2, 0, 0.0215);
    col += GETPIXEL(0, 2, 0.0215);
    col += GETPIXEL(0, -2, 0.0215);
    
    // 3Ä­.
    col += GETPIXEL(-1, 2, 0.0131);
    col += GETPIXEL(-2, 1, 0.0131);
    col += GETPIXEL(-2, -1, 0.0131);
    col += GETPIXEL(-1, -2, 0.0131);
    col += GETPIXEL(1, -2, 0.0131);
    col += GETPIXEL(2, -1, 0.0131);
    col += GETPIXEL(2, 1, 0.0131);
    col += GETPIXEL(1, 2, 0.0131);
    col += GETPIXEL(0, 3, 0.0018);
    col += GETPIXEL(-3, 0, 0.0018);
    col += GETPIXEL(0, -3, 0.0018);
    col += GETPIXEL(3, 0, 0.0018);
    
    // 4Ä­.
    col += GETPIXEL(-2, 2, 0.0029);
    col += GETPIXEL(-2, -2, 0.0029);
    col += GETPIXEL(2, -2, 0.0029);
    col += GETPIXEL(2, 2, 0.0029);
    col += GETPIXEL(-1, 3, 0.0011);
    col += GETPIXEL(-3, 1, 0.0011);
    col += GETPIXEL(-3, -1, 0.0011);
    col += GETPIXEL(-1, -3, 0.0011);
    col += GETPIXEL(1, -3, 0.0011);
    col += GETPIXEL(3, -1, 0.0011);
    col += GETPIXEL(3, 1, 0.0011);
    col += GETPIXEL(1, 3, 0.0011);
    col += GETPIXEL(-4, 0, 0.0001);
    col += GETPIXEL(0, 4, 0.0001);
    col += GETPIXEL(4, 0, 0.0001);
    col += GETPIXEL(0, -4, 0.0001);
    
    // 5Ä­.
    col += GETPIXEL(-2, 3, 0.0002);
    col += GETPIXEL(-3, 2, 0.0002);
    col += GETPIXEL(-3, -2, 0.0002);
    col += GETPIXEL(-2, -3, 0.0002);
    col += GETPIXEL(2, -3, 0.0002);
    col += GETPIXEL(3, -2, 0.0002);
    col += GETPIXEL(3, 2, 0.0002);
    col += GETPIXEL(2, 3, 0.0002);
    col += GETPIXEL(-1, 4, 0.00005);
    col += GETPIXEL(-4, 1, 0.00005);
    col += GETPIXEL(-4, -1, 0.00005);
    col += GETPIXEL(-1, -4, 0.00005);
    col += GETPIXEL(1, -4, 0.00005);
    col += GETPIXEL(4, -1, 0.00005);
    col += GETPIXEL(4, 1, 0.00005);
    col += GETPIXEL(1, 4, 0.00005);
    
    Color = col.rgb;
    Alpha = col.a;
}





/*void SumBlur_float(UnityTexture2D Tex, float2 Uv0, float Power, out float3 Color, out float Alpha)
{
    #define GETPIXEL(offsetx, offsety, gaussian)  SAMPLE_TEXTURE2D(Tex.tex, Tex.samplerstate, Uv0)

    float4 col = GETPIXEL(0,0,1);
     Power *= 0.005;
    #define GETPIXEL(offsetx, offsety, gaussian) SAMPLE_TEXTURE2D(Tex.tex, Tex.samplerstate, Uv0 + float2(offsetx * Power, offsety * Power)) * gaussian
    
    // °¡¿îµ¥.
    float4 col = GETPIXEL(0, 0, 0.1592);

    Color = col;
    Alpha = 1;
}
*/


#endif //MYHLSLINCLUDE_INCLUDED

