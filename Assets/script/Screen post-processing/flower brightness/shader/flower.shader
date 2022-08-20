Shader "Custom/flower"
{
    Properties
    {
        _MainTex ("BaseMap", 2D) = "white"{}
        _Brightness ("Brightness", float) = 1
        _Saturation ("Saturation", float) = 1
        _Contrast ("Contrast", float) = 1
    }
    SubShader
    {
        Pass{

            ZTest Always Cull Off ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            struct v2f {

                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;

            };

            v2f vert(appdata_img v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed4 renderTex = tex2D(_MainTex, i.uv);
                fixed3 finalColor = renderTex.rgb * _Brightness;
                fixed Iuminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 IuminanceColor = fixed3(Iuminance, Iuminance, Iuminance);
                finalColor = lerp(IuminanceColor, finalColor, _Saturation);

                fixed3 avgColor = fixed3(0.5f, 0.5f, 0.5f);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, renderTex.a);

            }

            ENDCG

        }
    }
    FallBack "Diffuse"
}
