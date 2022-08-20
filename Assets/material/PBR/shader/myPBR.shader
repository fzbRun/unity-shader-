Shader "Custom/myPBR"
{
    Properties
    {
        _EnvironmentMap ("_EnvironmentMap", CUBE) = "_Skybox"{}
        
    }
    SubShader
    {
        
        Tags { "RenderType" = "Opaque" }

        CGINCLUDE

        #include "UnityCG.cginc"

        samplerCUBE _EnvironmentMap;

        struct a2v {

            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;

        };

        struct v2f {

            float4 pos : SV_POSITION;
            float3 normal : TEXCOORD0;
            float2 uv : TEXCOORD1;
            float3 localPos : TEXCOORD2;

        };

        v2f vert(a2v v) {

            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.localPos = fixed3()
            o.normal = UnityObjectToWorldNormal(v.normal);
            o.uv = v.texcoord;

        }

        fixed4 frag(v2f i) : SV_TARGET{

            

        }

        ENDCG

    }
    FallBack "Diffuse"
}
