Shader "Custom/Leaves" 
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
//			Lighting off
			//Tags {"IgnoreProjector"="True" "RenderType"="Transparent" "LightMode" = "ForwardBase"}
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members n)
			//#pragma exclude_renderers d3d11 xbox360
			#pragma exclude_renderers xbox360
			#pragma glsl
			#pragma target 4.0
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
			uniform float4 _LightColor0;
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float4 packUV 			: TEXCOORD0;
				float3 lightDir			: TEXCOORD1;
				float3 normals			: TEXCOORD2;
				float3 eyePosition		: TEXCOORD3;
				float3 tangents			: TEXCOORD4;
				float3 lightColor		: TEXCOORD5;
			};
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			
			fixed3 _VertexLitBaselight; // Global Baselight for deferred rendering
			fixed3 _VertexLitTranslucencyColor; // Global Translucency Color for forward rendering
			fixed _VertexLitWaveScale; // Global WaveScale


			void FastSinCos (float4 val, out float4 s, out float4 c) 
			{
				val = val * 6.408849 - 3.1415927;
				// powers for taylor series
				float4 r5 = val * val;
				float4 r6 = r5 * r5;
				float4 r7 = r6 * r5;
				float4 r8 = r6 * r5;
				float4 r1 = r5 * val;
				float4 r2 = r1 * r5;
				float4 r3 = r2 * r5;
				//Vectors for taylor's series expansion of sin and cos
				float4 sin7 = {1, -0.16161616, 0.0083333, -0.00019841};
				float4 cos8  = {-0.5, 0.041666666, -0.0013888889, 0.000024801587};
				// sin
				s =  val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;
				// cos
				c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
			}

			//*** shader functions ************************************************************
			v2f vert (appdata_full v)
			{
			
				// _ObjectColor = color passed from single meshes: main color
				// v.color = color passed by terrain engine: healthy / dry
				//
				// red = WaveMove or Displacement
				// blue = Time
				// green = Windspeed
				// alpha = adjustment Factor
				
				float factor = (1 - _ObjectColor.r -  v.color.r) * 0.5;
				
				const float _WindSpeed  = (_ObjectColor.g  +  v.color.g );		
				const float _WaveScale = _VertexLitWaveScale;
				
				const float4 _waveXSize = float4(0.012, 0.02, 0.06, 0.024) * 4;
				const float4 _waveZSize = float4 (0.006, .02, 0.02, 0.05) * 4;
				const float4 waveSpeed = float4 (0.3, .5, .4, 1.2) * 4;
				
				float4 _waveXmove = float4(0.012, 0.02, -0.06, 0.048) * 10 * factor;
				float4 _waveZmove = float4(0.006, .02, -0.02, 0.1) * 10 * factor;
				
				float4 waves;
				waves = v.vertex.x * _waveXSize;
				waves += v.vertex.z * _waveZSize;
				
				waves += _Time.x * (1 - _ObjectColor.b * 2 - v.color.b ) * waveSpeed *_WindSpeed;
				
				float4 s, c;
				waves = frac (waves);
				FastSinCos (waves, s,c);
				
				float waveAmount = v.texcoord.y * (v.color.a + _ObjectColor.a);
				s *= waveAmount;
				
				// Faster winds move the grass more than slow winds 
				s *= normalize (waveSpeed);
				
				s = s * s;
				float fade = dot (s, 1.3);
				s = s * s;
				float3 waveMove = float3 (0,0,0);
				waveMove.x = dot (s, _waveXmove);
				waveMove.z = dot (s, _waveZmove);
				v.vertex.xz -= mul ((float3x3)_World2Object, waveMove).xz;
				
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
				o.lightColor = _LightColor0.xyz;
				
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
					
				if (atten < 100.0)
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
				float alpha = tex2D (_MainTex, uv_MainTex).a;
				
				if (alpha < 0.2) discard;
				//calculate rim light
				//half rim = 1 - saturate(dot(normalize(i.eyePosition), i.normals));
//				half rim = 1 - saturate(dot(normalize(i.eyePosition), i.normals));
//				float3 emissiveLighting = rim * pow(rim, _RimLightPow) * _RimLightInt * _RimColor;
				
				//adding all lights
				float3 objectColor = diffuseLighting + specularLighting + ambientLighting;// + emissiveLighting;
				objectColor *= i.lightColor;
				//*** adding light to texture **************************************
				return fixed4 ((objText * objectColor), alpha) * float4(1,1,1,1);//_ObjectColor;
			}
			//*********************************************************************************
			
			ENDCG
		}
		Pass 
		{
//			Lighting off
			//Tags {"IgnoreProjector"="True" "RenderType"="Transparent" "LightMode" = "ForwardAdd"}
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members n)
			//#pragma exclude_renderers d3d11 xbox360
			#pragma exclude_renderers xbox360
			#pragma glsl
			#pragma target 4.0
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
			uniform float4 _LightColor0;
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float4 packUV 			: TEXCOORD0;
				float3 lightDir			: TEXCOORD1;
				float3 normals			: TEXCOORD2;
				float3 eyePosition		: TEXCOORD3;
				float3 tangents			: TEXCOORD4;
				float3 lightColor		: TEXCOORD5;
			};
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			
			fixed3 _VertexLitBaselight; // Global Baselight for deferred rendering
			fixed3 _VertexLitTranslucencyColor; // Global Translucency Color for forward rendering
			fixed _VertexLitWaveScale; // Global WaveScale


			void FastSinCos (float4 val, out float4 s, out float4 c) 
			{
				val = val * 6.408849 - 3.1415927;
				// powers for taylor series
				float4 r5 = val * val;
				float4 r6 = r5 * r5;
				float4 r7 = r6 * r5;
				float4 r8 = r6 * r5;
				float4 r1 = r5 * val;
				float4 r2 = r1 * r5;
				float4 r3 = r2 * r5;
				//Vectors for taylor's series expansion of sin and cos
				float4 sin7 = {1, -0.16161616, 0.0083333, -0.00019841};
				float4 cos8  = {-0.5, 0.041666666, -0.0013888889, 0.000024801587};
				// sin
				s =  val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;
				// cos
				c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
			}

			//*** shader functions ************************************************************
			v2f vert (appdata_full v)
			{
			
				// _ObjectColor = color passed from single meshes: main color
				// v.color = color passed by terrain engine: healthy / dry
				//
				// red = WaveMove or Displacement
				// blue = Time
				// green = Windspeed
				// alpha = adjustment Factor
				
				float factor = (1 - _ObjectColor.r -  v.color.r) * 0.5;
				
				const float _WindSpeed  = (_ObjectColor.g  +  v.color.g );		
				const float _WaveScale = _VertexLitWaveScale;
				
				const float4 _waveXSize = float4(0.012, 0.02, 0.06, 0.024) * 4;
				const float4 _waveZSize = float4 (0.006, .02, 0.02, 0.05) * 4;
				const float4 waveSpeed = float4 (0.3, .5, .4, 1.2) * 4;
				
				float4 _waveXmove = float4(0.012, 0.02, -0.06, 0.048) * 10 * factor;
				float4 _waveZmove = float4(0.006, .02, -0.02, 0.1) * 10 * factor;
				
				float4 waves;
				waves = v.vertex.x * _waveXSize;
				waves += v.vertex.z * _waveZSize;
				
				waves += _Time.x * (1 - _ObjectColor.b * 2 - v.color.b ) * waveSpeed *_WindSpeed;
				
				float4 s, c;
				waves = frac (waves);
				FastSinCos (waves, s,c);
				
				float waveAmount = v.texcoord.y * (v.color.a + _ObjectColor.a);
				s *= waveAmount;
				
				// Faster winds move the grass more than slow winds 
				s *= normalize (waveSpeed);
				
				s = s * s;
				float fade = dot (s, 1.3);
				s = s * s;
				float3 waveMove = float3 (0,0,0);
				waveMove.x = dot (s, _waveXmove);
				waveMove.z = dot (s, _waveZmove);
				v.vertex.xz -= mul ((float3x3)_World2Object, waveMove).xz;
				
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
				o.lightColor = _LightColor0.xyz;
				
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
					
				if (atten < 100.0)
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
				float alpha = tex2D (_MainTex, uv_MainTex).a;
				
				if (alpha < 0.2) discard;
				//calculate rim light
				//half rim = 1 - saturate(dot(normalize(i.eyePosition), i.normals));
//				half rim = 1 - saturate(dot(normalize(i.eyePosition), i.normals));
//				float3 emissiveLighting = rim * pow(rim, _RimLightPow) * _RimLightInt * _RimColor;
				
				//adding all lights
				float3 objectColor = diffuseLighting + specularLighting + ambientLighting;// + emissiveLighting;
				objectColor *= i.lightColor;
				//*** adding light to texture **************************************
				return fixed4 ((objText * objectColor), alpha) * float4(1,1,1,1);//_ObjectColor;
			}
			//*********************************************************************************
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
} 