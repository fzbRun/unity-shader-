Shader "Custom/fogWithNoise"
{
    Properties
    {
       _MainTex ("MainTex", 2D) = "white"{}
       _FogDensity ("Fog Density", float) = 1.0
       _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
       _FogStrat ("Fog Strat", float) = 0.0
       _FogEnd ("Fog End", float) = 1.0
       _NoiseTex ("Noise Texture", 2D) = "white"{}
       _FogXSpeed ("Fpg Horizontal Speed", float) = 0.1
       _FogYSpeed ("Fog Vertical Speed", float) = 0.1
       _NoiseAmount ("Noise Amount", float) = 1
    }
    SubShader
    {
        
        CGINCLUDE

        #include "UnityCG.cginc"

        float4x4 _FrustumCornersRay;
        sampler2D _CameraDepthTexture;

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;
        sampler2D _NoiseTex;
        float _FogXSpeed;
        float _FogYSpeed;
        float _NoiseAmount;

        struct v2f {

            float4 pos : SV_POSITION;
            float4 uv : TEXCOORD0;
            float4 interpolatedRay : TEXCOORD1;

        };

        v2f vert(appdata_img v) {

            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_START_AT_TOP
            if (_MainTex_TexelSize < 0.0f) {
                o.uv.w = 1.0f - o.uv.w;
            }
            #endif

            /*
            int index = 0;
            if (v.texcoord.x < 0.5f && v.texcoord.y < 0.5f) {
                index = 0;
            }
            else if (v.texcoord.x > 0.5f && v.texcoord.y < 0.5f) {
                index = 1;
            }
            else if (v.texcoord.x > 0.5f && v.texcoord.y > 0.5f) {
                index = 2;
            }
            else {
                index = 3;
            }
            */
            //优化一下，减少if else
            int index = step(0.5f, o.uv.z) + step(0.5f, o.uv.w) * (1 + 2 * step(o.uv.z, 0.5f));

            /*
            #if UNITY_UV_START_AT_TOP
            if (_MainTex_TexelSize < 0.0f) {
                index = 3 - index;
            }
            #endif
            */

            o.interpolatedRay = _FrustumCornersRay[index];

            return o;

        }

        fixed4 frag(v2f i) : SV_TARGET{

            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw));
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay;

            float2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);
            float noise = (tex2D(_NoiseTex, i.uv.xy + speed).r - 0.5f) * _NoiseAmount;

            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDensity * (1.0f + noise));

            fixed4 finalColor = tex2D(_MainTex, i.uv.xy);
            finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

            return finalColor;
        }

        ENDCG

		Pass {     

			CGPROGRAM  
			
            #pragma vertex vert
            #pragma fragment frag 
			  
			ENDCG
		}

    }
    FallBack "Diffuse"
}
