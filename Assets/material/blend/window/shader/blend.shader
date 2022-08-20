Shader "Custom/blend"
{
    Properties
    {

        _BlendMap ("blendMap", 2D) = "white" {}
        _Gloss("Gloss", Range(8.0,256)) = 20

    }
    SubShader
    {

        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RnderType" = "Transparent"}

        pass {

            Tags { "LightModel" = "ForwardBase" }

            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include"Lighting.cginc"

            sampler2D _BlendMap;
            fixed _Gloss;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texCoords : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 FragPos : TEXCOORD2;

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texCoords.xy;
                o.FragPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.FragPos);
                fixed3 normal = normalize(i.normal);
                fixed3 h = normalize(lightDir + viewDir);
                fixed3 objectColor = tex2D(_BlendMap, i.uv).rgb;

                fixed3 diffuse = _LightColor0.rgb * saturate(dot(normal, lightDir));
                fixed3 specular =_LightColor0.rgb * pow(saturate(dot(normal, h)), _Gloss);

                fixed3 color = (ambient + diffuse + specular) * objectColor;
                fixed alpha = tex2D(_BlendMap, i.uv).w;

                return fixed4(color,alpha);

            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}
