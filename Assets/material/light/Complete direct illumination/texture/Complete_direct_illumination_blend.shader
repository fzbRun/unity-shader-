Shader "Custom/transparent_square"
{
    Properties
    {

        _BlendMap("BlendMap", 2D) = "white" {}
        _Gloss("Gloss", Range(8,256)) = 20
        _Cutoff("Cutoff",Range(0,1)) = 0.5

    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" "IgnorProjection" = "True" "Queue" = "Transparent" }

            pass {

                Blend SrcAlpha OneMinusSrcAlpha
                Cull front

                CGPROGRAM

                #pragma multi_compile_fwdbase
                #pragma vertex vert
                #pragma fragment frag
                #include"Lighting.cginc"
                #include"AutoLight.cginc"

                sampler2D _BlendMap;
                half _Gloss;
                fixed _Cutoff;

                struct a2v {

                    float4 pos : POSITION;
                    float3 normal : NORMAL;
                    float4 uv : TEXCOORD0;

                };

                struct v2f {

                    float4 pos : SV_POSITION;
                    float3 FragPos : TEXCOORD0;
                    float3 normal : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                    SHADOW_COORDS(3)

                };

                v2f vert(a2v v) {

                    v2f o;

                    o.pos = UnityObjectToClipPos(v.pos);
                    o.FragPos = mul(unity_ObjectToWorld, v.pos);
                    o.normal = UnityObjectToWorldNormal(v.normal);
                    o.uv = v.uv.xy;
                    TRANSFER_SHADOW(o);

                    return o;

                }

                fixed4 frag(v2f i) : SV_TARGET{

                    fixed3 normal = normalize(i.normal);
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.FragPos));
                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.FragPos));
                    fixed3 h = normalize(lightDir + viewDir);

                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    fixed3 diffuse = _LightColor0.rgb * (saturate(dot(lightDir, normal)) * 0.5f + 0.5f);
                    fixed3 specular = _LightColor0.rgb * pow(saturate(dot(h, normal)), _Gloss);

                    fixed3 objectColor = tex2D(_BlendMap, i.uv).rgb;
                    fixed alpha = tex2D(_BlendMap, i.uv).w;
                    UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                    fixed3 color = (ambient + (diffuse + specular) * atten) * objectColor;

                    return fixed4(color, alpha);

                }

                ENDCG

            }

            pass {

                Tags { "LightModel" = "ForwardBase" }

                Blend SrcAlpha OneMinusSrcAlpha
                Cull back

                CGPROGRAM

                #pragma multi_compile_fwdbase
                #pragma vertex vert
                #pragma fragment frag
                #include"Lighting.cginc"
                #include"AutoLight.cginc"

                sampler2D _BlendMap;
                half _Gloss;
                fixed _Cutoff;

                struct a2v {

                    float4 pos : POSITION;
                    float3 normal : NORMAL;
                    float4 uv : TEXCOORD0;

                };

                struct v2f {

                    float4 pos : SV_POSITION;
                    float3 FragPos : TEXCOORD0;
                    float3 normal : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                    SHADOW_COORDS(3)

                };

                v2f vert(a2v v) {

                    v2f o;

                    o.pos = UnityObjectToClipPos(v.pos);
                    o.FragPos = mul(unity_ObjectToWorld, v.pos);
                    o.normal = UnityObjectToWorldNormal(v.normal);
                    o.uv = v.uv.xy;
                    TRANSFER_SHADOW(o);

                    return o;

                }

                fixed4 frag(v2f i) : SV_TARGET{

                    fixed3 normal = normalize(i.normal);
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.FragPos));
                    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.FragPos));
                    fixed3 h = normalize(lightDir + viewDir);

                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                    fixed3 diffuse = _LightColor0.rgb * (saturate(dot(lightDir, normal)) * 0.5f + 0.5f);
                    fixed3 specular = _LightColor0.rgb * pow(saturate(dot(h, normal)), _Gloss);

                    fixed3 objectColor = tex2D(_BlendMap, i.uv).rgb;
                    fixed alpha = tex2D(_BlendMap, i.uv).w;
                    UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                    fixed3 color = (ambient + (diffuse + specular) * atten ) * objectColor;

                    return fixed4(color, alpha);

                }

                ENDCG

            }

        }
            //FallBack "Transparent/Count/VertexLit"//Í¸Ã÷¶ÈÌÞ³ý
        FallBack "VertexLit"
}
