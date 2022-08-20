Shader "Custom/Complete_direct_illumination"
{
        Properties
        {
            _AlbedoMap ("Albedo", 2D) = "white" {}
            _NormalMap ("Normal",2D) = "white" {}
            _Gloss("Gloss", Range(8,256)) = 20
        }
        SubShader
        {
               Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

               Pass{    //最重要的平行光照

                    Tags{ "LightMode" = "ForwardBase"}

                    CGPROGRAM

                    #pragma multi_compile_fwdbase
                    #pragma vertex vert
                    #pragma fragment frag
                    #include"UnityCG.cginc"
                    #include"Lighting.cginc"
                    #include"AutoLight.cginc"

                    sampler2D _AlbedoMap;
                    sampler2D _NormalMap;
                    half _Gloss;

                   struct a2v {

                        float4 vertex : POSITION;
                        float3 normal : NORMAL;
                        float4 tangent : TANGENT;
                        float4 texCoord : TEXCOORD0;

                   };

                   struct v2f {

                        float4 pos : SV_POSITION;
                        float3 FragPos : TEXCOORD0;
                        float3 lightDir : TEXCOORD1;
                        float3 viewDir : TEXCOORD2;
                        float2 uv : TEXCOORD3;
                        SHADOW_COORDS(4)

                   };

                   v2f vert(a2v v) {

                        v2f o;
                        o.pos = UnityObjectToClipPos(v.vertex);
                        o.FragPos = mul(unity_ObjectToWorld, v.vertex).xyz;//世界空间

                        fixed3 pos = mul(UNITY_MATRIX_MV, v.vertex).xyz;
                        fixed3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));//观察空间
                        fixed3 tangent = normalize(mul(UNITY_MATRIX_MV, v.tangent)).xyz;
                        fixed3 bitangent = normalize(cross(tangent, normal));
                        fixed3x3 TBN = fixed3x3(tangent, bitangent, normal);//按行排，所以直接是转置

                        o.lightDir = mul(TBN, mul((float3x3)UNITY_MATRIX_IT_MV, ObjSpaceLightDir(v.vertex)));
                        o.viewDir = mul(TBN, mul((float3x3)UNITY_MATRIX_IT_MV, ObjSpaceViewDir(v.vertex)));
                        o.uv = v.texCoord.xy;
                        TRANSFER_SHADOW(o);

                        return o;

                   }

                   fixed4 frag(v2f i) : SV_TARGET{

                        fixed3 normal = tex2D(_NormalMap,i.uv);
                        fixed4 objectColor = tex2D(_AlbedoMap, i.uv);
                        fixed3 h = normalize(i.lightDir + i.viewDir);

                        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                        fixed3 diffuse = _LightColor0.xyz * saturate( dot(normal, i.lightDir) * 0.5f + 0.5f );
                        fixed3 specular = _LightColor0.xyz * pow(saturate(dot(h, normal)), _Gloss);

                        UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                        return fixed4((ambient + (diffuse + specular) * atten) * objectColor.xyz, objectColor.a);

                   }
               
                    ENDCG

               }

                Pass{   //逐像素光照

                       Tags {"LightModel" = "ForwardAdd" }

                       Blend one one

                       CGPROGRAM

                       #pragma multi_compile_fwdadd_fullshadows
                       #pragma vertex vert
                       #pragma fragment frag
                       #include "Lighting.cginc"
                       #include "AutoLight.cginc"

                       sampler2D _AlbedoMap;
                       sampler2D _NormalMap;
                       half _Gloss;

                       struct a2v {

                           float4 vertex : POSITION;
                           float3 normal : NORMAL;
                           float4 tangent : TANGENT;
                           float4 texCoord : TEXCOORD0;

                       };

                       struct v2f {

                           float4 pos : SV_POSITION;
                           float3 FragPos : TEXCOORD0;
                           float3 lightDir : TEXCOORD1;
                           float3 viewDir : TEXCOORD2;
                           float2 uv : TEXCOORD3;
                           SHADOW_COORDS(5)

                       };

                       v2f vert(a2v v) {

                           v2f o;
                           o.pos = UnityObjectToClipPos(v.vertex);
                           o.FragPos = mul(unity_ObjectToWorld,v.vertex).xyz;//世界空间

                           fixed pos = mul(UNITY_MATRIX_MV, v.vertex).xyz;
                           fixed3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));//观察空间
                           fixed3 tangent = normalize(mul(UNITY_MATRIX_MV, v.tangent)).xyz;
                           fixed3 bitangent = normalize(cross(tangent, normal));
                           fixed3x3 TBN = fixed3x3(tangent, bitangent, normal);

                           o.lightDir = mul(TBN, ObjSpaceLightDir(v.vertex));
                           o.viewDir = mul(TBN, ObjSpaceViewDir(v.vertex));
                           o.uv = v.texCoord.xy;
                           TRANSFER_SHADOW(o);

                           return o;

                       }

                       fixed4 frag(v2f i) : SV_TARGET{

                            fixed3 normal = tex2D(_NormalMap,i.uv);
                            fixed4 objectColor = tex2D(_AlbedoMap, i.uv);
                            fixed3 h = normalize(i.lightDir + i.viewDir);


                            fixed3 diffuse = _LightColor0.xyz * saturate(dot(normal, i.lightDir) * 0.5f + 0.5f);
                            fixed3 specular = _LightColor0.xyz * pow(saturate(dot(h, normal)), _Gloss);

                            UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                            return fixed4((diffuse + specular) * atten * objectColor.xyz, objectColor.a);

                       }

                       ENDCG

                }

        }

        FallBack "Specular"

}
