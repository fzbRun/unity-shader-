Shader "Custom/light"{

	Properties{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_AlbedoMap("AlbedoMap",2D) = "white"{}
		_NormalMap("NormalMap",2D) = "white"{}
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

	SubShader{
		Pass{

			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include"Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			sampler2D _AlbedoMap;
			float4 _AlbedoMap_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texCoords : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v v) {
				
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				fixed3 normal = normalize(UnityObjectToWorldNormal(v.normal)).xyz;	//世界空间
				fixed3 tangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 bitangent = normalize(cross(normalize(tangent), normal) * v.tangent.w);
				float3x3 TBN = float3x3(normalize(v.tangent.xyz), bitangent, normal);
				float3x3 TBN_T = transpose(TBN);

				o.lightDir = normalize(mul(TBN_T, WorldSpaceLightDir(v.vertex)));	//切线空间
				o.viewDir = normalize(mul(TBN_T, WorldSpaceViewDir(v.vertex)));	//切线空间

				o.uv.xy = v.texCoords.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
				o.uv.zw = v.texCoords.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

				return o;

			}

			fixed4 frag(v2f i) : SV_TARGET{

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 objectAlbedo = tex2D(_AlbedoMap, i.uv.xy).rgb;
				fixed3 lightDir = i.lightDir;
				fixed3 viewDir = i.viewDir;
				fixed3 h = normalize(lightDir + viewDir);
				fixed3 normal = tex2D(_NormalMap, i.uv.zw).rgb;

				fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(normal, lightDir));
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(normal, h)), _Gloss);

				fixed3 color = (ambient + diffuse + specular) * objectAlbedo;

				return fixed4(color,1.0f);

			}

			ENDCG

		}
	}

	FallBack"Specular"

}
