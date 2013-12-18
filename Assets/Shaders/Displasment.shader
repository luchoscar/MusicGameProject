Shader "Custom/Displasment" 
{	Properties 
	{
		_LightColor		("Light Color", Color)				= (1.0, 1.0, 1.0, 1.0)	
		_ObjectColor	("Object Color", Color)				= (1.0, 0.5, 0.25, 1.0)	
		_AmbientInt		("Ambient Light Intensity", float)	= 0.25
		_MainTex		("Texture", 2D)						= "white" { }
		_BumpMap		("Bump Map", 2D)					= "bump" {}			
		_DispMap		("Displasment Map", 2D)				= "gray" {}		
		_DispRange		("Displasment Range", Range(-2.5, 2.5))	= 0.0
	}
	
	SubShader 
	{
		Pass 
		{
			//Lighting off
			
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members n)
			//#pragma exclude_renderers d3d11 xbox360
			#pragma exclude_renderers xbox360
			//#pragma glsl
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float4			_LightColor;
			float4 			_ObjectColor;
			float 			_AmbientInt;
			sampler2D 		_MainTex;
			sampler2D 		_BumpMap;
			sampler2D		_DispMap;
			float			_DispRange;
			
			uniform float3 lightPos;
			uniform float3 cameraPos;
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float2 packUV			: TEXCOORD0;
			};
			
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			//float4 _DispMap_ST;
			
			v2f vert (appdata_full v)
			{
				TANGENT_SPACE_ROTATION;
				
				//*** calculate light direction & distance ***************************
				float3 P = v.vertex.xyz;
				
				float disp = tex2Dlod(_DispMap,(v.texcoord)).a * _DispRange;
				
				P += v.normal * disp;
				
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, float4(P, 1));
				o.packUV = TRANSFORM_TEX ((v.texcoord), _MainTex);
				
				return o;	
			}
			
			//pixel shader
			half4 frag (v2f i) : COLOR
			{
				float2 uv_MainTex = i.packUV;
				
				//*** calculating point light color ********************************
				float textColor = tex2D (_MainTex, uv_MainTex).xyz;
				float3 mainLight = _ObjectColor.rgb * textColor;
				
				return fixed4 ((mainLight), 1) * _LightColor;
			}
			//*********************************************************************************
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
} 