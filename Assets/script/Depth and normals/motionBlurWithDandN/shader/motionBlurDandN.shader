Shader "Custom/motionBlurDandN"
{
    Properties
    {
       _MainTex ("MainTex", 2D) = "white"{}
       _blurSize("Blur Size", float) = 0.5
    }
    SubShader
    {
       CGINCLUDE

        #include "UnityCG.cginc"

       sampler2D _PreviousMainTex;

       sampler2D _MainTex;
       half4 _MainTex_TexelSize;
       sampler2D _CameraDepthTexture;
       float4x4 _CurrentViewProjectionInverseMatrix;
       float4x4 _PreviousViewProjectionMatrix;
       half _blurSize;

       struct v2f {

           float4 pos : SV_POSITION;
           half2 uv : TEXCOORD0;
           half2 uv_depth : TEXCOORD1;

       };

       v2f vert(appdata_img v) {

           v2f o;

           o.pos = UnityObjectToClipPos(v.vertex);
           o.uv = v.texcoord;
           o.uv_depth = v.texcoord;

           #if UNITY_UV_STARTS_AT_TOP
           if (_MainTex_TexelSize.y < 0) {
               o.uv_depth.y = 1.0f - o.uv_depth.y;
           }
           #endif

           return o;

       }

       fixed4 frag(v2f i) : SV_TARGET{

           float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
           float4 H = float4(i.uv, d, 1.0f) * 2 - 1.0f; //ndc
           float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
           float4 worldPos = D / D.w;

           float4 currentPos = H;
           float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
           previousPos = previousPos / previousPos.w;

           float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;
           
           float2 uv = i.uv;
           //float4 color = tex2D(_MainTex, uv);
           float4 c = tex2D(_MainTex, uv);
           uv += velocity * _blurSize;
           for (int i = 1; i < 3; i++, uv += velocity * _blurSize) {
               
               float4 currentColor = tex2D(_MainTex, uv);
               c += currentColor;

           }

           c /= 3;
           //color += c;
           return fixed4(c.rgb, 1.0f);

       }

       ENDCG

       Pass {

           ZTest Always Cull Off ZWrite Off

           CGPROGRAM

           #pragma vertex vert
           #pragma fragment frag

           ENDCG

       }

    }

    FallBack "Diffuse"
}
