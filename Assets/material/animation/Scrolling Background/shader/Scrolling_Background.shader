Shader "Custom/Scrolling_Background"
{
    Properties
    {
        _nearMap ("nearMap", 2D) = "white"{}
        _farMap ("farMap", 2D) = "white"{}
        _nearScrollx ("nearScrollxSpeed", float) = 0.5
        _farScrollx("farScrollxSpeed", float) = 0.5
        _Brightness ("Brightness", float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass{

                Tags {"LightMode" = "ForwardBase"}

                CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                sampler2D _nearMap;
                float4 _nearMap_ST;
                sampler2D _farMap;
                float4 _farMap_ST;
                float _nearScrollx;
                float _farScrollx;
                float _Brightness;

                struct a2v {

                    float4 vertex : POSITION;
                    float4 texCoord : TEXCOORD0;

                };

                struct v2f {

                    float4 pos : SV_POSITION;
                    float4 uv : TEXCOORD0;

                };

                v2f vert(a2v v) {

                    v2f o;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv.xy = TRANSFORM_TEX(v.texCoord, _nearMap) + frac(float2(_nearScrollx, 0.0f) * _Time.y);//frac函数返回小数部分
                    o.uv.zw = TRANSFORM_TEX(v.texCoord, _farMap) + frac(float2(_farScrollx, 0.0f) * _Time.y);

                    return o;

                }

                fixed4 frag(v2f i) : SV_TARGET{

                    fixed4 firstLayer = tex2D(_nearMap, i.uv.xy);
                    fixed4 secondLayer = tex2D(_farMap, i.uv.zw);

                    fixed4 color = lerp(secondLayer, firstLayer, firstLayer.a);
                    color *= _Brightness;

                    return color;

                }

                ENDCG

            }
        

    }
    FallBack "Diffuse"
}
