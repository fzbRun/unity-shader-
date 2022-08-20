Shader "Custom/Procedural textures"
{
    Properties
    {
        _AlbedoMap ("Albedo (RGB)", 2D) = "white" {}
        _Gloss ("Gloss", Range(8,256)) = 20
    }
    SubShader
    {

        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass{

            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            sampler2D _AlbedoMap;
            half _Gloss;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texCoord : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float4 FragPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD2;

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.FragPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.uv = v.texCoord.xy;

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 lightDir = normalize(WorldSpaceLightDir(i.FragPos));
                fixed3 viewDir = normalize(WorldSpaceViewDir(i.FragPos));
                fixed3 h = normalize(viewDir + lightDir);
                fixed3 objectColor = tex2D(_AlbedoMap, i.uv).rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(i.normal, lightDir));
                fixed3 specular = _LightColor0.rgb * pow(saturate(dot(i.normal, h)), _Gloss);

                fixed3 color = (ambient + diffuse + specular) * objectColor;

                return fixed4(color, 1.0f);

            }

            ENDCG

        }
        
    }
    FallBack "Diffuse"
}
