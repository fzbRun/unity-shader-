Shader "Custom/billboard"
{
    Properties
    {
        _BillboardfMap ("BillboardMap", 2D) = "white"{}
        _VerticalBillboarding ("VerticalBillboarding", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True" }

        Pass{

            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _BillboardMap;
            float4 _BillboardMap_ST;
            fixed _VerticalBillboarding;

            struct a2v {

                float4 vertex : POSITION;
                float4 texCoord : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;

            };

            v2f vert(a2v v) {

                v2f o;

                float3 center = float3(0.0f, 0.0f, 0.0f);
                float3 viewPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0f));

                float3 normalDir = viewPos - center;
                normalDir.y = normalDir.y * _VerticalBillboarding;
                normalDir = normalize(normalDir);

                float3 upDir = abs(normalDir.y) > 0.999f ? float3(0.0f, 0.0f, 1.0f) : float3(0.0f, 1.0f, 0.0f);
                float3 rightDir = normalize(cross(normalDir, upDir));
                upDir = normalize(cross(normalDir, rightDir));

                float3 centerOffs = v.vertex.xyz - center;
                float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos(float4(localPos, 1.0f));
                o.uv = TRANSFORM_TEX(v.texCoord, _BillboardMap);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed4 color = tex2D(_BillboardMap, i.uv);
                return color;

            }

            ENDCG

        }
        
    }
    FallBack "Transpatent/VertexLits"
}
