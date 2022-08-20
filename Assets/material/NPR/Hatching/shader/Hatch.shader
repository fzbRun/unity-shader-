Shader "Custom/Hatching"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _TileFactor("Tile Factor", Float) = 1
        _Outline("Outline", Range(0, 1)) = 0.1
        _Hatch0("Hatch 0", 2D) = "white" {}
        _Hatch1("Hatch 1", 2D) = "white" {}
        _Hatch2("Hatch 2", 2D) = "white" {}
        _Hatch3("Hatch 3", 2D) = "white" {}
        _Hatch4("Hatch 4", 2D) = "white" {}
        _Hatch5("Hatch 5", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        UsePass "Custom/ToonShading/OUTLINE"

        Pass{

            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            //#include "UnityShaderVariables.cginc"

            fixed4 _Color;
            half _TileFactor;
            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float3 FragPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 hatchWeight0 : TEXCOORD2;
                float3 hatchWeight1 : TEXCOORD3;
                SHADOW_COORDS(4)

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord * _TileFactor;

                fixed3 lightDir = normalize(WorldSpaceLightDir(v.vertex));
                fixed3 viewDir = normalize(WorldSpaceViewDir(v.vertex));
                fixed3 normal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 halfDir = normalize(lightDir + viewDir);

                fixed diff = max(0, dot(lightDir, normal));
                fixed spec = dot(normal, halfDir);
                fixed light = diff + spec;

                o.hatchWeight0 = fixed3(0.0f, 0.0f, 0.0f);
                o.hatchWeight1 = fixed3(0.0f, 0.0f, 0.0f);
                float hatchFactor = diff * 7.0f;

                if (hatchFactor > 6.0f) {

                }
                else if (hatchFactor > 5.0f) {
                    o.hatchWeight0.x = hatchFactor - 5.0f;
                }
                else if (hatchFactor > 4.0f) {
                    o.hatchWeight0.x = hatchFactor - 4.0f;
                    o.hatchWeight0.y = 1.0f - o.hatchWeight0.x;
                }                
                else if (hatchFactor > 3.0f) {
                    o.hatchWeight0.y = hatchFactor - 3.0f;
                    o.hatchWeight0.z = 1.0f - o.hatchWeight0.y;
                }                
                else if (hatchFactor > 2.0f) {
                    o.hatchWeight0.z = hatchFactor - 2.0f;
                    o.hatchWeight1.x = 1.0f - o.hatchWeight0.z;
                }                
                else if (hatchFactor > 1.0f) {
                    o.hatchWeight1.x = hatchFactor - 1.0f;
                    o.hatchWeight1.y = 1.0f - o.hatchWeight1.x;
                }                
                else{
                    o.hatchWeight1.y = hatchFactor;
                    o.hatchWeight1.z = 1.0f - o.hatchWeight1.y;
                }

                o.FragPos = mul(unity_ObjectToWorld, v.vertex);

                TRANSFER_SHADOW(o);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeight0.x;
                fixed4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeight0.y;
                fixed4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeight0.z;
                fixed4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeight1.x;
                fixed4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeight1.y;
                fixed4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeight1.z;
                fixed4 white = fixed4(1.0f, 1.0f, 1.0f, 1.0f) * (1.0f - i.hatchWeight0.x - i.hatchWeight0.y - i.hatchWeight0.z - i.hatchWeight1.x - i.hatchWeight1.y - i.hatchWeight1.z);
                fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + white;

                UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                return fixed4(hatchColor.rgb * _Color.rgb * atten, 1.0f);

            }

            ENDCG

        }

    }
        FallBack "Diffuse"
}
