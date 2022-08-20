Shader "Custom/refraction"
{
    Properties
    {

        _RefractColor("RefractColor_Color", Color) = (1,1,1,1)
        _RefractAmount ("Refraction_Amount", Range(0,1)) = 1
        _RefractRatio ("Reftac_Ratio", Range(0.1,1)) = 0.5
        _Gloss ("Gloss", Range(8,256)) = 20
        _CubeMap ("Refraction_CubeMap", Cube) = "_Skybox"{}

    }
    SubShader
    {

        Tags {"RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass{

            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"

            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            half _Gloss;
            samplerCUBE _CubeMap;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float3 FragPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 refractDir : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                SHADOW_COORDS(4)

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.FragPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.FragPos));
                o.refractDir = refract(-viewDir, o.normal, _RefractRatio);

                TRANSFER_SHADOW(o);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.FragPos));
                fixed3 h = normalize(i.viewDir + lightDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(i.normal, lightDir));
                fixed3 specular = _LightColor0.rgb * pow(saturate(dot(i.normal, h)), _Gloss);

                fixed3 refraction = texCUBE(_CubeMap, i.refractDir).rgb * _RefractColor.rgb;

                UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                return fixed4(ambient + lerp(diffuse + specular, refraction, _RefractAmount) * atten, 1.0f);

            }

            ENDCG

        }

    }
    FallBack "Reflective/VertexLit"
}
