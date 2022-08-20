Shader "Custom/mirror"
{
    Properties
    {
        _mirrorMap ("mirrorMap", 2D) = "white"{}
    }
        SubShader
    {

        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass{

            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma multi_complie_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _mirrorMap;

            struct a2v {

                float4 vertex : POSITION;
                float2 texCoord : TEXCOORD0;

            };

            struct v2f {

                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;

            };

            v2f vert(a2v v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texCoord;
                o.uv.x = 1.0f - o.uv.x;

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                return tex2D(_mirrorMap,i.uv);

            }

            ENDCG

        }

    }
    FallBack "Diffuse"
}
