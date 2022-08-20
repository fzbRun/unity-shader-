Shader "Custom/glass"
{
    Properties
    {
        _GlossMap ("GlossMap",2D) = "white"{}
        _NormalMap ("NormalMap",2D) = "bump"{}
        _CubeMap ("CubeMap",Cube) = "_Skybox"{}
        _Distortion ("Distortion", Range(0,100)) = 10
        _RefractAmount ("Refract Amount", Range(0.0,1.0)) = 1.0

    }
    SubShader
    {
        
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }

        GrabPass{ "_RefractionTex" }

        Pass{

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GlossMap;
			float4 _GlossMap_ST;
            sampler2D _NormalMap;
			float4 _NormalMap_ST;
            samplerCUBE _CubeMap;
            half _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v {

                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texCoord : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float3 TtoW0 : TEXCOORD1;
                float3 TtoW1 : TEXCOORD2;
                float3 TtoW2 : TEXCOORD3;
                float4 uv : TEXCOORD4;
                float3 FragPos : TEXCORD5;

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);
                o.FragPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 normal = UnityObjectToWorldNormal(v.normal);
				o.uv.xy = TRANSFORM_TEX(v.texCoord, _GlossMap);
				o.uv.zw = TRANSFORM_TEX(v.texCoord, _NormalMap);

				fixed3 tangent = UnityObjectToWorldDir( v.tangent.xyz);
                fixed3 bitangent = cross(normal, tangent) * v.tangent.w;

                o.TtoW0 = fixed3(tangent.x,bitangent.x,normal.x);
                o.TtoW1= fixed3(tangent.y,bitangent.y,normal.y);
                o.TtoW2 = fixed3(tangent.z,bitangent.z,normal.z);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed3 normal = UnpackNormal(tex2D(_NormalMap,i.uv.zw));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.FragPos));

                float2 offset = normal.xy * _Distortion;// * _RefractionTex_TexelSize.xy去掉才有效果，输出为蓝色，所以这个值的xy为0，不知道为啥。
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

                normal = normalize(half3(dot(i.TtoW0, normal), dot(i.TtoW1, normal), dot(i.TtoW2, normal)));
                fixed3 reflDir = reflect(-viewDir, normal);
                fixed4 texColor = tex2D(_GlossMap, i.uv.xy);
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb;

                fixed3 color = reflCol * (1.0f - _RefractAmount) + refrCol * _RefractAmount;

                return fixed4(color, 1.0f);

            }

            ENDCG

        }

    }
    FallBack "Diffuse"
}