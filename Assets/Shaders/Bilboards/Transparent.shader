Shader "Custom/Cg shader using blending" 
{
	Properties 
	{
		_MainText 	("Base (RGB)", 2D) = "white" {}
	}
	
	SubShader 
	{
		Tags { "Queue" = "Transparent" } 
		// draw after all opaque geometry has been drawn
		Pass 
		{
			//ZWrite Off // don't write to depth buffer 
			// in order not to occlude other objects
			
			Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
			
			CGPROGRAM 
			
			#pragma vertex vert 
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct FS_INPUT
			{
				float4	pos		: SV_POSITION;
				float2  packUV	: TEXCOORD0;
			};
			
			sampler2D _MainText;
			float4 _MainText_ST;
			
			FS_INPUT vert(appdata_full v)
			{
				TANGENT_SPACE_ROTATION;
				
				FS_INPUT o;
				
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.packUV = TRANSFORM_TEX ((v.texcoord), _MainText);
				return o;
			}
			
			half4 frag(FS_INPUT i) : COLOR 
			{
				float2 uv_MainTex = i.packUV;
				
				float3 mainColor = tex2D (_MainText, uv_MainTex).xyz;
				return half4(mainColor, 0.3); 
				// the fourth component (alpha) is important: 
				// this is semitransparent green
			}
			
			ENDCG  
		}
	}
}