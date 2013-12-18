Shader "Custom/PerPixelLight" 
{
	Properties 
	{
		_ObjectColor	("Object Color", Color)				= (1.0, 1.0, 1.0, 1.0)	
		_AmbientInt		("Ambient Light Intensity", float)	= 0.25
		_LightInt		("Light Intensity", float)			= 1.0
		_MainTex		("Texture", 2D)						= "white" { }
		_BumpMap		("Bumpmap", 2D)						= "bump" {}			
		
		_RimColor		("Rim Light Color", Color)			= (1.0, 1.0, 1.0, 1.0)
		_RimLightPow	("Rim Light Power", float)			= 2.0
		_RimLightInt	("Rim Light Intensity", float)		= 1.0
	}
	
	SubShader 
	{
		Pass 
		{
			Lighting off
			
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members n)
			//#pragma exclude_renderers d3d11 xbox360
			#pragma exclude_renderers xbox360
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float4 			_ObjectColor;
			float 			_AmbientInt;
			float			_LightInt;
			sampler2D 		_MainTex;
			sampler2D		_BumpMap;
			
			float4			_RimColor;
			float 			_RimLightPow;
			float			_RimLightInt;
			
			uniform float3	lightPos;
			uniform float3	eyePos;
			uniform int	lightRange;
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float4 packUV 			: TEXCOORD0;
				float3 lightDir			: TEXCOORD1;
				float3 normals			: TEXCOORD2;
				float3 eyePosition		: TEXCOORD3;
				float3 tangents			: TEXCOORD4;
			};
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			
			//*** shader functions ************************************************************
			v2f vert (appdata_full v)
			{
				TANGENT_SPACE_ROTATION;
				
				//*** calculate light direction & distance, camera position *******************
				float3 P = v.vertex.xyz;
				
				//lightPos = mul(_World2Object, float4 (lightPos, 1)).xyz;
				float3 lightDirection = lightPos - mul(_Object2World, v.vertex).xyz;
				
				//eyePos = mul(_World2Object, float4 (eyePos, 1)).xyz - P;
				
				//setting output variable
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, float4(P, 1));
				o.packUV.xy = TRANSFORM_TEX ((v.texcoord), _MainTex);
				o.packUV.zw = TRANSFORM_TEX ((v.texcoord), _BumpMap);
				o.lightDir = lightDirection;
				o.normals = mul(_Object2World, float4(v.normal, 0)).xyz;
				o.eyePosition = eyePos;
				o.tangents = v.tangent.xyz;
				
				return o;	
			}
			
			//pixel shader
			half4 frag (v2f i) : COLOR
			{
				float2 uv_MainTex =i.packUV.xy;
				float2 uv_BumpTex =i.packUV.zw;
				
				//converting from tangent to object space
				float3 T = normalize(i.tangents);
				float3 N = normalize(i.normals);
				float3 B = normalize(cross(T, N));
				
				float3x3 TBN = transpose(float3x3(T, B, N));
				//i.normals = (tex2D(_BumpMap, i.packUV.zw).xyz - 0.5) * 2.0;// - 1.0;
				i.normals = (tex2D(_BumpMap, i.packUV.zw).xyz *2.0 - 1.0);// - 0.5) * 2.0;// - 1.0;
				i.normals = normalize(i.normals);
				i.normals = normalize(mul(TBN, i.normals));
				
				
				//*** calculating point light color ********************************
				float3 objText = tex2D(_MainTex, i.packUV.xy).xyz;
				
				float3 diffuseLighting = float3(0,0,0);
				float3 specularLighting = float3(0,0,0);
				
				float atten = length(i.lightDir);
//				atten = log(atten);

//				if (atten < 5)
//					atten = 1.0;
					
				if (atten < 100)
				{
					//calculate diffuse
					float3 L = normalize(i.lightDir);
					float diffuseInt = saturate(dot(L, i.normals));
					diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * _LightInt * saturate(1 - atten / 100);
					
					//specular light
					float3 V = normalize(i.eyePosition);
					float3 H = normalize(L + V);
					float specularInt = pow(saturate(dot(H, i.normals)), 2.0);
					specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * _LightInt * saturate(1 - atten / 100);
				}
				
				//calculate ambient
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				
				//calculate rim light
				//half rim = 1 - saturate(dot(normalize(i.eyePosition), i.normals));
//				half rim = 1 - saturate(dot(normalize(i.eyePosition), i.normals));
//				float3 emissiveLighting = rim * pow(rim, _RimLightPow) * _RimLightInt * _RimColor;
				
				//adding all lights
				float3 objectColor = diffuseLighting + specularLighting + ambientLighting;// + emissiveLighting;
				
				//*** adding light to texture **************************************
				return fixed4 ((objText * objectColor), 1) * _ObjectColor;
			}
			//*********************************************************************************
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
} 