Shader "Custom/treeWind" 
{	Properties 
	{
		_LightColor		("Light Color", Color)				= (1.0, 1.0, 1.0, 1.0)	
		_ObjectColor	("Object Color", Color)				= (1.0, 1.0, 1.0, 1.0)	
		_MainTex		("Main Texture", 2D)				= "white" { }
		_Bend			("Tree bend", float)				= 0.0
		_BendOffset		("Offset bend", float)				= 0.0
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
			
			float _Bend;
			float _BendOffset;
			float4 _LightColor;
			float4 _ObjectColor;
			sampler2D _MainTex;
			
			uniform float time;
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float2 packUV			: TEXCOORD0;
			};
			
			
			float4 _MainTex_ST;
//			float4 _BumpMap_ST;
			
			v2f vert (appdata_full v)
			{
				TANGENT_SPACE_ROTATION;
				
				//*** calculate light direction & distance ***************************
				float3 P = v.vertex.xyz;
				_Bend += _BendOffset;
				
//				P[0] *= cos(P[0] * 3.1416) * cos(P[0] * 3.1416) * cos(P[0] * 3.1416 * 3) * cos(P[0] * 3.1416 * 5) * 0.5 + sin(P[0] * 3.1416 * 25) * 0.02;
				P[0] += sin(P[1]) * max(P[1]	 * _BendOffset, 0);
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, float4(P, 1));
//				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.packUV = TRANSFORM_TEX ((v.texcoord), _MainTex);
//				o.packUV = v.texcoord;
				
				return o;	
			}
			
			//pixel shader
			half4 frag (v2f i) : COLOR
			{
				float2 uv_MainTex = i.packUV;
				
				//*** calculating point light color ********************************
				float3 textColor = tex2D (_MainTex, uv_MainTex).xyz;
				float3 mainLight = _ObjectColor.rgb * textColor;
				
				return fixed4 ((mainLight), 1) * _LightColor;
			}
			//*********************************************************************************
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
} 