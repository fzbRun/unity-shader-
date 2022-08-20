Shader "Custom/dissolve"
{
    Properties
    {
        _BurnAmount ("Burn Amount", Range(0.0, 1.0)) = 0.0
        _LineWidth ("Burn Line Width", Range(0.0, 0.2)) = 0.1
        _MainTex ("Main Tex", 2D) = "white"{}
        _BumpMap ("Normal Map", 2D) = "bump"{}
        _BurnFirstColor ("Burn First Color", Color) = (1, 0, 0, 1)
        _BurnSecondColor ("Burn Second Color", Color) = (1, 0, 0, 1)
        _BurnMap ("Burn Map", 2D) = "white"{}
    }
        SubShader
    {

        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass{

            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed _BurnAmount;
            fixed _LineWidth;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float3 lightDir : TEXCOORD0;
                float2 uvMainTex : TEXCOORD1;
                float2 uvBumpMap : TEXCOORD2;
                float2 uvBurnMap : TEXCOORD3;
                float3 FragPos : TEXCOORD4;
                SHADOW_COORDS(5)

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.FragPos = mul(unity_ObjectToWorld, v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

                TRANSFER_SHADOW(o);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                
                clip(burn.r - _BurnAmount);

                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

                fixed3 albedo = tex2D(_MainTex, i.uvMainTex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(tangentLightDir, tangentNormal));

                //噪音小的地方剔除，噪音大的地方(噪音大小大于_LineWidth, t=1)保留原来的颜色，只有噪音和和_BurnAmount大小差不多的地方认为是边缘，t=0
                //比如当_BurnAmount=0.1,那么可能原来噪音值为0.05的会变成烧焦的颜色，而当_BrunAmount变为0.2时，那噪音值为0.1的也会变为烧焦的颜色，那么烧焦的颜色区域就变大了。(在减去_BurnAmount的前提下）
                fixed t = 1.0f - smoothstep(0.0f, _LineWidth, burn.r - _BurnAmount);//(x-a)^2 / (b-a)^2 * (3 - 2 * (x-a) / (b-a))
                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                burnColor = pow(burnColor, 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.FragPos);

                fixed3 finalColor = lerp((ambient + diffuse * atten) * albedo, burnColor, t * step(0.00001f, _BurnAmount)); // a + w * (b - a)

                return fixed4(finalColor, 1.0f);

            }

            ENDCG

        }

        Pass{

            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            fixed _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            struct v2f {

                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD1;

            };

            v2f vert(appdata_base v) {

                v2f o;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);

                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;

                clip(burn.r - _BurnAmount);

                SHADOW_CASTER_FRAGMENT(i);
            }

            ENDCG

        }

    }
    FallBack "Diffuse"
}
