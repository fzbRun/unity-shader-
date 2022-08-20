Shader "Custom/waterWave"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0.15, 0.115, 1)
        _MainTex ("MainTex", 2D) = "white"{}
        _WaveMap ("WaveMap", 2D) = "white"{}
        _CubeMap ("CubeMap", Cube) = "_Skybox"{}
        _WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01
        _WaveYSpeed("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01
        _Distortion ("Distortion", Range(0, 100)) = 10
    }
    SubShader
    {
        
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }

        GrabPass {"_RefractionTex"} //只能抓取队列值（Queue）为3000以下的，也就是Transparent队列之前的。

        Pass{

            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _WaveMap;
            float4 _WaveMap_ST;
            samplerCUBE _CubeMap;
            fixed _WaveXSpeed;
            fixed _WaveYSpeed;
            half _Distortion;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v{
            
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            
            };

            struct v2f {

                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                float3 FragPos = mul(unity_ObjectToWorld, v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

                fixed3 normal = normalize(v.normal);
                fixed3 tangent = normalize(v.tangent.xyz);
                fixed3 bitangent = normalize(cross(normal, tangent) * v.tangent.w);

                o.TtoW0 = fixed4(tangent.x, bitangent.x, normal.x, FragPos.x);
                o.TtoW1 = fixed4(tangent.y, bitangent.y, normal.y, FragPos.y);
                o.TtoW2 = fixed4(tangent.z, bitangent.z, normal.z, FragPos.z);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                float2 speed = _Time.y * float2(_WaveXSpeed, _WaveYSpeed);
                float3 FragPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(FragPos));
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);

                fixed3 bump0 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
                fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
                fixed3 bump = normalize(bump0 + bump1);

                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w);

                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                //fixed3 refrDir = refract(-viewDir, bump, 0.5f);
                //fixed3 refrCol = texCUBE(_CubeMap, refrDir).rgb * texColor.rgb * _Color.rgb;

                fixed3 reflDir = reflect(-viewDir, bump);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb * _Color.rgb;

                fixed fresnel = pow(1.0f - saturate(dot(viewDir, bump)), 4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1.0f - fresnel);

                return fixed4(finalColor, 1.0f);

            }

            ENDCG

        }

    }
    FallBack "Diffuse"
}
