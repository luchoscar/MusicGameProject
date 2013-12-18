Shader "MusicGame/FloorLevitScript" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it does not contain a surface program or both vertex and fragment programs.
		#pragma exclude_renderers gles
		#pragma glsl
		#pragma target 3.0
		#pragma vertex vert
		#pragma surface surf Lambert
		
		//vertex variables
		uniform float3 playerPos;	//player position in object local space
		uniform float3 playerFwd;	//player forward vector in object local space
		
		//tessalatin variables
		//pixel variable
		
		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};
		
//		struct v2f 
//		{
//			float4 v_pos : SV_POSITION;
//			float2 uv_MainTex : TEXCOORD0;
//		}
		
		void vert (inout appdata_full v)
		{
			TANGENT_SPACE_ROTATION;
			
			float3 p = v.vertex.xyz;
			playerPos[1] = p[1];
			playerFwd[1] = p[1];
			playerFwd = normalize(playerFwd);
			
			float maxAngle = 3.1416 * 3 * 0.5;	// 3 * PI / 2
			float3 dist = p - playerPos;
			if (length(dist) <= maxAngle)
			{
				maxAngle += dist;
				
				float dotProd = min(dot(playerFwd, normalize(dist)), 0);
				p[1] += sin(maxAngle) * dotProd;
			}
			
			v.vertex = float4(p, 1);
		}
			
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack off
}
