Shader "Custom/bloom"
{
    Properties
    {
       _MainTex ("MainTex", 2D) = "white"{}
        _Bloom ("BloomMap", 2D) = "white"{}
        _LuminaceThreshold ("LuminanceThreshold", float) = 0.6
        _BlurSize ("Blur Size", float) = 1.0
    }
    SubShader
    {

        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminaceThreshold;
        float _BlurSize;

        struct v2f {

            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;

        };

        struct v2fBloom {

            float4 pos : SV_POSITION;
            half4 uv : TEXCOORD0;

        };

        fixed luminance(fixed4 color) {
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        v2f vertExtracBright(appdata_img v) {

            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;

        }

        fixed4 fragExtracBright(v2f i) : SV_TARGET{

            fixed4 c = tex2D(_MainTex, i.uv);
            fixed val = clamp(luminance(c) - _LuminaceThreshold, 0.0f, 1.0f);

            return c * val;

        }

        v2fBloom vertBloom(appdata_img v) {

            v2fBloom o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0.0f) {
                o.uv.w = 1.0f - o.uv.w;
            }
            #endif

            return o;

        }

        fixed4 fragBloom(v2fBloom i) : SV_TARGET{
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
        }

        ENDCG

        Pass{

            CGPROGRAM

            #pragma vertex vertExtracBright
            #pragma fragment fragExtracBright

            ENDCG

        }

        UsePass "Custom/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
        UsePass "Custom/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass{

            CGPROGRAM

            #pragma vertex vertBloom
            #pragma fragment fragBloom

            ENDCG

        }

    }
    FallBack "Diffuse"
}
