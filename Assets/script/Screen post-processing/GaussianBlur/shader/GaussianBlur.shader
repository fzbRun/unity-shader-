Shader "Custom/GaussianBlur"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
        _BlurSize("Blur Size", float) = 0.6
    }
        SubShader
        {
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f {

            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;

        };

        v2f vertBlurVertical(appdata_img v) {

            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + _MainTex_TexelSize * half2(0.0f, 1.0f) * _BlurSize;
            o.uv[2] = uv - _MainTex_TexelSize * half2(0.0f, 1.0f) * _BlurSize;
            o.uv[3] = uv + _MainTex_TexelSize * half2(0.0f, 2.0f) * _BlurSize;
            o.uv[4] = uv - _MainTex_TexelSize * half2(0.0f, 2.0f) * _BlurSize;

            return o;

        }

        v2f vertBlurHorizontal(appdata_img v) {

            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;
            o.uv[0] = uv;
            o.uv[1] = uv + _MainTex_TexelSize * half2(1.0f, 0.0f) * _BlurSize;
            o.uv[2] = uv - _MainTex_TexelSize * half2(1.0f, 0.0f) * _BlurSize;
            o.uv[3] = uv + _MainTex_TexelSize * half2(2.0f, 0.0f) * _BlurSize;
            o.uv[4] = uv - _MainTex_TexelSize * half2(2.0f, 0.0f) * _BlurSize;

            return o;

        }

        fixed4 fragBlur(v2f i) : SV_TARGET{

            float weight[3] = {0.4026f, 0.2442f, 0.0545};
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

            for (int k = 1; k < 3; k++) {

                sum += tex2D(_MainTex, i.uv[2 * k - 1]).rgb * weight[k];
                sum += tex2D(_MainTex, i.uv[2 * k]).rgb * weight[k];

            }

            return fixed4(sum, 1.0f);

        }

        ENDCG

        ZTest Always Cull Off ZWrite Off

        Pass{
        
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM

            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG

        }

        Pass{

            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM

            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG

        }

    }

    FallBack "Diffuse"

}
