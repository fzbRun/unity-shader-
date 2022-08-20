Shader "Custom/batching"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 128)) = 20
    }
    SubShader
    {
        
        Tags { "RenderType" = "Opaque" }

        Pass{

            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            half _Gloss;

            struct v2f {

                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;

            };

            v2f vert(appdata_base v){
            
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;

            }

            fixed4 frag(v2f i) : SV_Target{

                float4 worldPos = i.worldPos;
                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(WorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(WorldSpaceViewDir(worldPos));
                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = saturate(dot(lightDir, normal)) * _LightColor0.rgb;
                fixed3 specular = pow(saturate(dot(halfDir, normal)), _Gloss) * _LightColor0.rgb;

                return fixed4((ambient + diffuse + specular) * _Color, 1.0f);

            }

            ENDCG

        }

    }
    FallBack Off
}
