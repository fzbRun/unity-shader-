Shader "Custom/water"
{
    Properties
    {
        _WaterMap ("WaterMap", 2D) = "white"{}
        _Amplitude ("Amplitude", float) = 1
        _Frequency ("Frequency", float) = 1
        _InvWaveLength ("Distortion Inverse Wave Length", float) = 10
        _Speed ("Speed", float) = 30
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}//DisableBatching取消批处理
        
        Pass{
            
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _WaterMap;
            float4 _WaterMap_ST;
            float _Amplitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

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

                float4 offset;
                offset.yzw = float3(0.0f, 0.0f, 0.0f);
                offset.x = sin(_Frequency * _Time.y + (v.vertex.x + v.vertex.y + v.vertex.z) * _InvWaveLength) * _Amplitude;

                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.texCoord, _WaterMap) + float2(0.0f, _Time.y * _Speed);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                fixed4 color = tex2D(_WaterMap, i.uv);
                
                return color;

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

            float _Amplitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct v2f {

                V2F_SHADOW_CASTER;

            };

            v2f vert(appdata_base v) {

                v2f o;

                float4 offset;
                offset.yzw = float3(0.0f, 0.0f, 0.0f);
                offset.x = sin(_Frequency * _Time.y + (v.vertex.x + v.vertex.y + v.vertex.z) * _InvWaveLength) * _Amplitude;

                v.vertex = v.vertex + offset;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                SHADOW_CASTER_FRAGMENT(i);

            }

            ENDCG

        }

    }
    FallBack "Transpatent/VertexLit"
}
