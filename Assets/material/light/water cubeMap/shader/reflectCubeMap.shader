Shader "Custom/cubeMap"
{
    Properties
    {
        _FresnelScale("Fresnel Scale", Range(0,1)) = 0.5
        _CubeMap ("CubeMap", CUBE) = "_Skybox" {}
        _Gloss ("Gloss", Range(8,256)) = 20
    }
    SubShader
    {

        Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

        pass {

            Tags { "LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include"Lighting.cginc" 
            #include"AutoLight.cginc"

            fixed _FresnelScale;
            samplerCUBE _CubeMap;
            half _Gloss;

            struct a2v {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float4 texCoords : TEXCOORD0;
            };

            struct v2f {
                fixed4 pos : SV_POSITION;
                fixed3 FragPos : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.pos);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.FragPos = mul(unity_ObjectToWorld, v.pos);
                TRANSFER_SHADOW(o);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.FragPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.FragPos));
                fixed3 h = normalize(lightDir + viewDir);
                fixed3 reflectDir = reflect(-viewDir, normal);
                fixed3 reflection = texCUBE(_CubeMap, reflectDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(lightDir, normal));
                fixed3 specular = _LightColor0.rgb * pow(saturate(dot(h, normal)), _Gloss);

                fixed fresnel = _FresnelScale + (1.0f - _FresnelScale) * pow(1.0f - dot(viewDir, normal), 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                fixed3 color = ambient + (diffuse + lerp(specular, reflection, fresnel)) * atten;

                return fixed4(color, 1.0f);

            }

            ENDCG

        }
    }
    FallBack "Diffuse"
}
