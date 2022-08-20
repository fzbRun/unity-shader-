Shader "Custom/EdgeDetection"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white"{}
        _EdesOnly("Edge Only", float) = 1.0
        _EdgeColor("Edge Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _BackgroundColor ("Background Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass{

            ZTest Always Cull Off ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            struct v2f {

                float4 pos : SV_POSITION;
                float2 uv[9] : TEXCOORD0;

            };

            v2f vert(appdata_img v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                half2 uv = v.texcoord;
                o.uv[0] = uv + _MainTex_TexelSize * half2(-1.0f, -1.0f);
                o.uv[1] = uv + _MainTex_TexelSize * half2(0.0f, -1.0f);
                o.uv[2] = uv + _MainTex_TexelSize * half2(1.0f, -1.0f);
                o.uv[3] = uv + _MainTex_TexelSize * half2(-1.0f, 0.0f);
                o.uv[4] = uv + _MainTex_TexelSize * half2(0.0f, 0.0f);
                o.uv[5] = uv + _MainTex_TexelSize * half2(-1.0f, 0.0f);
                o.uv[6] = uv + _MainTex_TexelSize * half2(-1.0f, 1.0f);
                o.uv[7] = uv + _MainTex_TexelSize * half2(0.0f, 1.0f);
                o.uv[8] = uv + _MainTex_TexelSize * half2(1.0f, 1.0f);

                return o;

            }

            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(v2f i) {

                const half Gx[9] = { -1.0f, -2.0f, -1.0f,
                                     0.0f, 0.0f, 0.0f,
                                    1.0f, 2.0f, 1.0f };
                const half Gy[9] = { -1.0f, 0.0f, 1.0f,
                                    -2.0f, 0.0f, 2.0f,
                                    -1.0f, 0.0f, 1.0f };
                half texColor;
                half edgeX = 0.0f;
                half edgeY = 0.0f;
                for (int k = 0; k < 9; k++) {

                    texColor = luminance(tex2D(_MainTex, i.uv[k]));
                    edgeX += texColor * Gx[k];
                    edgeY += texColor * Gy[k];

                }

                half edge = 1.0f - abs(edgeX) - abs(edgeY);

                return edge;

            }

            fixed4 frag(v2f i) : SV_TARGET{

                half edge = Sobel(i);
    
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);

            }

            ENDCG

        }
    }
    FallBack "Diffuse"
}
