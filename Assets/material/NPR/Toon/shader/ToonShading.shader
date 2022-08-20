Shader "Custom/ToonShading"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white"{}
        _Ramp ("Ramp Texture", 2D) = "white"{}
        _OutLine ("OutLine", Range(0, 1)) = 0.1
        _OutLineColor ("OutLine Color", Color) = (0, 0, 0, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
     }
    SubShader
    {

        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass{

            NAME "OUTLINE"

            CULL Front

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _OutLine;
            float4 _OutLineColor;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;

            };

            struct v2f {

                float4 pos : SV_POSITION;

            };

            v2f vert(a2v v) {

                v2f o;

                float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                normal.z = -abs(normal.z);
                pos = pos + float4(normalize(normal), 0.0f) * _OutLine;
                o.pos = mul(UNITY_MATRIX_P, pos);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{
                return float4(_OutLineColor.rgb, 1.0f);
            }

            ENDCG

        }

        Pass{

            Tags { "LightMode" = "ForwardBase" }

            Cull Back

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            //#include "UnityShaderVariables.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Ramp;
            fixed4 _Specular;
            fixed _SpecularScale;

            struct a2v {

                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 FragPos : TEXCOORD2;
                SHADOW_COORDS(3)

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.FragPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);

                TRANSFER_SHADOW(o);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.FragPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.FragPos));
                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed4 objectColor = tex2D(_MainTex, i.uv);
                fixed3 albedo = objectColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                fixed diff = dot(lightDir, normal);
                diff = (diff * 0.5f + 0.5f);
                fixed3 diffuse = _LightColor0.rgb * tex2D(_Ramp, float2(diff, diff)).rgb * albedo;

                fixed spec = dot(normal, halfDir);
                fixed w = fwidth(spec) * 2.0f;
                fixed3 specular = _Specular.rgb * lerp(0.0f, 1.0f, smoothstep(-w, w, spec + _SpecularScale - 1.0f)) * step(0.0001f, _SpecularScale);

                return fixed4(ambient + (diffuse + specular) * atten, 1.0f);

            }

            ENDCG

        }

    }
    FallBack "Diffuse"
}
