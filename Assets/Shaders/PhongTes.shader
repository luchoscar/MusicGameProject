Shader "MusicGame/PhongTes" 
{
	Properties 
	{
		_waveAmp ("Amplitude of Wave", Range(0,1)) = 0.75
		_minDist ("Min Tess Dist", float) = 0.05
		_maxDist ("Max Tess Dist", float) = 50.0
		_Tess ("Tessellation", Range(1,32)) = 4
		_EdgeLength ("Edge length", Range(2,50)) = 5
		_Phong ("Phong Strengh", Range(0,1)) = 0.5
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Color", color) = (1,1,1,0)
		_DispTex ("Disp Texture", 2D) = "gray" {}
		_Displacement ("Displacement", Range(0, 1.0)) = 0.3
		_NormalMap ("Normalmap", 2D) = "bump" {}
	}
	
	SubShader 
	{
        Tags { "RenderType"="Opaque" }
		LOD 300
		
		CGPROGRAM
		#pragma exclude_renderers xbox360
		//#pragma surface surf Lambert vertex:disp tessellate:tessEdge tessphong:_Phong nolightmap
		//#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance tessphong:_Phong nolightmap
		#pragma surface surf SimpleSpecular addshadow fullforwardshadows vertex:disp tessellate:tessDistance tessphong:_Phong nolightmap
		#include "Tessellation.cginc"
		
		#include "HLSLSupport.cginc"
		#include "UnityCG.cginc"

		struct appdata 
		{
			float4 vertex		: POSITION;
			float4 tangent		: TANGENT;
			float3 normal		: NORMAL;
			float2 texcoord		: TEXCOORD0;
//			float4x4 matrixNorm : TEXCOORD1;
//			float3 lightDir		: TEXCOORD2;
		};
		
		float _waveAmp;
		float _minDist;
		float _maxDist;
		float _Tess;
		float _Phong;
		float _EdgeLength;
		float _Displacement;
		sampler2D _DispTex;
		
		float4 tessDistance (appdata v0, appdata v1, appdata v2) 
		{
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, _minDist, _maxDist, _Tess);
		}
		
		uniform float3 playerPos;
		uniform float3 playerFwd;
		//uniform float3 lightPos;
		
		struct Input 
		{
			float2 uv_MainTex;
//			float3 lightDir;
			float3 tangent;
			float3 normal;			
		};
		
		//void disp (inout appdata v)//, out Input o)
		void disp (inout appdata v)
		{
//			TANGENT_SPACE_ROTATION;
			
			//*** calc vertex displacement
			float3 p = v.vertex.xyz;
			playerPos = mul(_World2Object, float4(playerPos, 1)).xyz;
			
			float amplitude = max(0.0125, abs(playerPos[1] - p[1]));
			
			playerPos[1] = p[1];
			playerFwd[1] = p[1];
			
			playerFwd = normalize(playerFwd);
			
			float maxAngle = 3.1416 * 3 * 0.5;	// 3 * PI / 2
			float3 dist = p - playerPos;
			float disp = 0.0;
			
			if (length(dist) <= maxAngle)
			{
				maxAngle += length(dist);
				
				float dotProd = max(dot(playerFwd, normalize(dist)), 0);
				disp = sin(maxAngle) * dotProd * _waveAmp;
			}
			
			//*** calc light direction & normal
			//lightPos = mul(_World2Object, float4(lightPos, 1)).xyz;
			
			v.vertex.y += disp / amplitude;
		}
		
		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalMap;
		
		//custom surface light function
		half4 LightingSimpleSpecular(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 H = normalize(lightDir + viewDir);
			
			half diff = max(0.125, dot(s.Normal, lightDir));
			
			float NH = saturate(dot(s.Normal, H));
			float spec = pow(NH, 48.0); 
			
			half NdotL = dot(s.Normal, lightDir) * 2.0 - 1.0;
			
			half4 c;
			
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2);
			c.a = s.Alpha;
			
			return c;
			
		}
		
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//IN.uv_MainTex[0] += (float)cos(_Time) * 0.25;
			IN.uv_MainTex[0] += (float)cos(_Time * 2) * 0.5;
			IN.uv_MainTex[1] += (float)_Time * 0.25;
				
			half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Specular = 0.2;
			o.Gloss = 1.0;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
		}
		
		ENDCG
	}
	
	FallBack "Diffuse"
}
