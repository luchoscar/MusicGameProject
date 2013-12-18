Shader "Custom/GeomShader" 
{
	Properties 
	{
		_SpriteTex 	("Base (RGB)", 2D) = "white" {}
		_SpriteAlp 	("Alpha (RGB)", 2D) = "white" {}
		_Size 		("Size", Range(0, 3)) = 0.5
//		_AlpCutOff	("Alpha Cut OffSize", Range(0, 1)) = 0.0
	}
	
	SubShader 
	{
		Pass
		{
			//Tags { "RenderType"="Opaque" }
			//Tags { "Queue" = "Transparent" } 
			LOD 200
			//Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
			CGPROGRAM
			
			#pragma target 5.0
			
			#pragma vertex VS_Main
			#pragma fragment FS_Main
			#pragma geometry GS_Main
			
			#include "UnityCG.cginc" 
			
			// **************************************************************
			// Data structures												*
			// **************************************************************
			struct GS_INPUT
			{
				float4	pos		: POSITION;
				float3	normal	: NORMAL;
				float2  tex0	: TEXCOORD0;
				float2  tex1	: TEXCOORD1;
			};
			
			struct FS_INPUT
			{
				float4	pos		: POSITION;
				float2  tex0	: TEXCOORD0;
			};
			
			
			// **************************************************************
			// Vars															*
			// **************************************************************
			
//			float _AlpCutOff;
			float _Size;
			float4x4 _VP;
			
			Texture2D _SpriteTex;
//			sampler2D _SpriteTex;
			SamplerState sampler_SpriteTex;
			
			sampler2D _SpriteAlp;
//			sampler2D _SpriteAlp;
//			SamplerState sampler_SpriteAlp;
			
			// **************************************************************
			// Shader Programs												*
			// **************************************************************
			
			// Vertex Shader ------------------------------------------------
			GS_INPUT VS_Main(appdata_base v)
			//GS_INPUT VS_Main(void)
			{
				float3 P = v.vertex.xyz;
				
				GS_INPUT output = (GS_INPUT)0;
				
				output.pos =  mul(_Object2World, float4(P, 1));
				//output.pos =  mul(_Object2World, float4(0,0,0, 1));
				//output.normal = v.normal;
				output.tex0 = float2(0, 0);
				
				return output;
			}
			
			// Geometry Shader -----------------------------------------------------
			[maxvertexcount(4)]
			void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
			{
				float3 up = float3(0, 1, 0);
				float3 look = _WorldSpaceCameraPos - p[0].pos;
				float3 camLook = normalize(look);
				look.y = 0;
				look = normalize(look);
				float3 right = cross(up, look);
				up = cross(camLook, right);
				float dotProd = acos(dot(camLook, look));
				
				float halfS = 0.5f * _Size;
				
				float4 v[4];
				v[0] = float4(p[0].pos + halfS * right - halfS * up, 1.0f);
//				v[0].z = length(v[0]) * cos(dotProd);
//				v[0].y = length(v[0]) * sin(dotProd);
				v[1] = float4(p[0].pos + halfS * right + halfS * up, 1.0f);
//				v[1].z = length(v[1]) * cos(dotProd);
//				v[1].y = length(v[1]) * sin(dotProd);
				v[2] = float4(p[0].pos - halfS * right - halfS * up, 1.0f);
//				v[2].z = length(v[2]) * cos(dotProd);
//				v[2].y = length(v[2]) * sin(dotProd);
				v[3] = float4(p[0].pos - halfS * right + halfS * up, 1.0f);
//				v[3].z = length(v[3]) * cos(dotProd);
//				v[3].y = length(v[3]) * sin(dotProd);
				
				float4x4 vp = mul(UNITY_MATRIX_MVP, _World2Object);
				
				FS_INPUT pIn;
				pIn.pos = mul(vp, v[0]);
				pIn.tex0 = float2(1.0f, 0.0f);
				triStream.Append(pIn);
				
				pIn.pos =  mul(vp, v[1]);
				pIn.tex0 = float2(1.0f, 1.0f);
				triStream.Append(pIn);
				
				pIn.pos =  mul(vp, v[2]);
				pIn.tex0 = float2(0.0f, 0.0f);
				triStream.Append(pIn);
				
				pIn.pos =  mul(vp, v[3]);
				pIn.tex0 = float2(0.0f, 1.0f);
				triStream.Append(pIn);
			}
			
			
			
			// Fragment Shader -----------------------------------------------
			float4 FS_Main(FS_INPUT input) : COLOR
			{
				float4 mainColor = _SpriteTex.Sample(sampler_SpriteTex, input.tex0);
				if (mainColor.a < 0.3)
					discard;
				
				return mainColor;
//				return _SpriteTex.Sample(sampler_SpriteTex, input.tex0);
			}
			
			ENDCG
		}	
	} 
}
