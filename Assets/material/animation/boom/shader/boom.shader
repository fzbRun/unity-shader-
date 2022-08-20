Shader "Custom/boom"
{
    Properties
    {
        _BoomMap ("BoomMap",2D) = "white"{}
        _HorizontalAmount ("Horizontal Amount", float) = 8
        _VerticalAmount ("Vertical Amount", float) = 8
        _Speed ("Speed", Range(0,100)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent"}
        
        Pass{

            Tags {"LightMode" = "ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _BoomMap;
            fixed4 _BoomMap_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

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
                o.uv = TRANSFORM_TEX(v.texCoord, _BoomMap);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                float time = floor(_Time.y * _Speed);//获得时间
                float row = floor(time / _HorizontalAmount);//得到行数
                float column = time - row * _VerticalAmount;//没超过一行就是列数

                half2 uv = i.uv + half2(column, -row);//偏移量
                uv.x /= _HorizontalAmount;//先缩放到第一幅图，在通过偏移量转到相应的行列数的图
                uv.y /= _VerticalAmount;

                fixed4 c = tex2D(_BoomMap, uv);
                
                return c;

            }

            ENDCG

        }

    }
    FallBack "Diffuse"
}
