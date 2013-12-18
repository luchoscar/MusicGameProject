Shader "Custom/ShaderSW_Floor" 
{
	Properties 
	{
		_ObjectColor	("Object Color", Color)				= (1.0, 0.5, 0.25, 1.0)	
		_AmbientInt		("Ambient Light Intensity", float)	= 0.25
		_MainTex		("Texture", 2D)						= "white" { }
		_BumpMap		("Bumpmap", 2D)						= "bump" {}	
		//_DispMap		("Displasment Map", 2D)				= "gray" {}		
		//_DispRange		("Displasment Range", Range(0, 1))	= 0		
	}
	
	SubShader 
	{
		Pass 
		{
			//Lighting off
			
			Tags { "LightMode" = "ForwardBase" } // pass for 
            // 4 vertex lights, ambient light & first pixel light
            
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members n)
			//#pragma exclude_renderers d3d11 xbox360
			//#pragma exclude_renderers xbox360
			
			#pragma glsl
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float4 			_ObjectColor;
			float 			_AmbientInt;
			sampler2D 		_MainTex;
			sampler2D 		_BumpMap;
			//sampler2D		_DispMap;
			//float			_DispRange;
			
			//light variables
			uniform int 	totalLights;
			uniform int 	lightType;
			//uniform float 	lightType;
			uniform float3 	lightPosition;
			uniform float3 	lightColor;
			uniform float 	lightRange;
			uniform float3	lightDirection;
			uniform float	lightConeAngle;
			uniform float	lightIntensity;
			uniform float	lightFallOffRange = 10;
			
			uniform float4 _LightColor0;
			
			//camera variables
			uniform float3 	cameraPosition;
			
			struct LightStruct
			{
				float2 packUV;
				float3 normals;
				float3 eyePosition;
				float3 lightColor;
				float3 lightDir;
				float lightRange;
				float3 lightForward;
			};
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float4 packUV 			: TEXCOORD0;
				float3 lightDir 		: TEXCOORD1;
				float3 normals 			: TEXCOORD2;
				float3 eyePosition		: TEXCOORD3;
				float lightRange		: TEXCOORD4;
				float3 lightForward		: TEXCOORD5;
				float3 lightColor		: TEXCOORD6;
				float3 vtang			: TEXCOORD7;
			};
			
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float4 _DispMap_ST;
			
			//*** custome function ************************************************************
			//function to calculate point light
			float3 CalculatePointLight(LightStruct i)
			{
				fixed2 uv_MainTex = i.packUV.xy;
				
				//*** calculating light color **************************************
				float3 lightColor;
				
				//ambient light
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				lightColor = ambientLighting;
				
				if(i.lightRange > 0)
				{
					//calculate diffuse
					float3 L = normalize(i.lightDir);
					float diffuseInt = max(dot(L, i.normals), 0);
					float3 diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * lightIntensity / i.lightRange;
					
					//specular light
					float3 V = normalize(i.eyePosition);
					float3 H = normalize(L + V);
					float specularInt = pow(max(dot(H, i.normals), 0.0), 2.0);
					float3 specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * lightIntensity / i.lightRange;
					
					//*** getting texture **********************************************
					float3 objTexture = tex2D (_MainTex, uv_MainTex);
					
					//calculate fall off
					lightColor += (diffuseLighting + specularLighting);
				}
				return lightColor * i.lightColor;
			}
			
			//function to calculate spot light
			float3 CalculateSpotLight(LightStruct i)
			{
				//*** calculate if vertex is within cone of light ******************
				bool withInConeLight = false;
				
				//calculate cone of light
				float dotProduct = dot(normalize(i.lightForward * -1), normalize((i.lightDir)));
				float angleCos = acos(dotProduct);
				float angleToLight = max(angleCos, 0);
				
				if (angleToLight <= lightConeAngle * 0.5) withInConeLight = true;
				
				
				//*** get UVs from vertex ******************************************
				fixed2 uv_MainTex = i.packUV.xy;
				
				//*** getting texture **********************************************
				float3 objTexture = tex2D (_MainTex, uv_MainTex);
				
				//*** calculating light color **************************************
				//ambient light
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				float3 lightColor = ambientLighting;
				
				if (withInConeLight)
				{
					//calculate diffuse
					float3 L = normalize(i.lightDir);
					float diffuseInt = max(dot(L, i.normals), 0);
					float3 diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * lightIntensity / i.lightRange;
					
					//specular light
					float3 V = normalize(i.eyePosition);
					float3 H = normalize(L + V);
					float specularInt = pow(max(dot(H, i.normals), 0.0), 2.0);
					float3 specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * lightIntensity / i.lightRange;
					
					lightColor += (diffuseLighting + specularLighting);
				}
				
				return lightColor * i.lightColor;
			}
			
			//function to calculate directional light
			float3 CalculateDirectionalLight(LightStruct i)
			{
				//*** calculate angle between vertex normal and light direction
				float3 crossProd = cross(normalize(i.normals), normalize(i.lightForward));
				float angleSin = sqrt(crossProd[0] * crossProd[0] + crossProd[1] * crossProd[1] + crossProd[2] * crossProd[2]);
				float angleCos = dot(normalize(i.normals), normalize(i.lightForward));
				
				float directionIntensity = 0;
				
				if (angleCos <= 0) 
				{
					directionIntensity = 1 - angleSin;
				}
				
				//*** get UVs from vertex ******************************************
				fixed2 uv_MainTex = i.packUV.xy;
				
				//*** getting texture **********************************************
				float3 objTexture = tex2D (_MainTex, uv_MainTex);
				
				//*** calculating light color **************************************
				//ambient light
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				
				//calculate diffuse
				float3 L = normalize(i.lightDir);
				float diffuseInt = max(dot(L, i.normals), 0);
				float3 diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * lightIntensity * directionIntensity;
				
				//specular light
				float3 V = normalize(i.eyePosition);
				float3 H = normalize(L + V);
				float specularInt = pow(max(dot(H, i.normals), 0.0), 2.0);
				float3 specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * lightIntensity * directionIntensity;
				
				float3 lightColor = diffuseLighting + specularLighting + ambientLighting;
				
				return lightColor * i.lightColor;
			}
			//*********************************************************************************
			
			//*** shader functions ************************************************************
			v2f vert (appdata_full v)
			{
				TANGENT_SPACE_ROTATION;
				
				//*** lidhtDirection has been pass as a vector already in object space ***/
				
				//convert camera and light to object space
				cameraPosition = mul(_World2Object, float4 (cameraPosition, 1)).xyz;
				lightPosition = mul(_World2Object, float4 (lightPosition, 1)).xyz;
				
				//*** calculate light direction & distance ***************************
				float3 P = v.vertex.xyz;
				
				//float disp = tex2Dlod(_DispMap,(v.texcoord)).a * _DispRange;
				//P += v.normal * disp;
				
				float3 lightDir = lightPosition - P;
				float directMag = sqrt(lightDir[0] * lightDir[0] + lightDir[1] * lightDir[1] + lightDir[2] * lightDir[2]);
				
				
				//rangeDist >= 0 										--> vertex within light range
				//rangeDist < -(lightFallOffRange)						--> vertex outside light range 
				//rangeDist < 0  && rangeDist >= -(lightFallOffRange)	--> vertex outside light range
				
				if (lightFallOffRange > 0) lightFallOffRange *= -1;
				float rangeDist = lightRange - directMag;
				
				if (rangeDist >= 0) lightRange = 1;
				else if (rangeDist <= lightFallOffRange) lightRange = -1;
				else 
				{
					if (rangeDist > -1) lightRange = 1 + abs(rangeDist);
					else lightRange = abs(rangeDist);
				}
				
				//setting output variable
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, float4(P, 1));
				o.vtang = v.tangent;
				o.packUV.xy = TRANSFORM_TEX ((v.texcoord), _MainTex);
				o.packUV.zw = TRANSFORM_TEX ((v.texcoord), _BumpMap);
				o.lightDir = lightDir;
				o.normals = v.normal;
				o.eyePosition = cameraPosition;
				o.lightRange = lightRange;
				o.lightForward = lightDirection;
				
				_ObjectColor = _LightColor0;
				o.lightColor = float3(_ObjectColor.rgb);
				
				
				return o;	
			}
			
			//pixel shader
			half4 frag (v2f i) : COLOR
			{
				//*** calculating point light color ********************************
				float3 mainLight;
				
				//converting from tangent to object space
				float3 T = normalize(i.vtang);
				float3 N = normalize(i.normals);
				float3 B = normalize(cross(T, N));
				
				float3x3 TBN = transpose(float3x3(T, B, N));
				i.normals = (tex2D(_BumpMap, i.packUV.zw) - 0.5) * 2.0;
				i.normals = normalize(mul(TBN, i.normals));
				
				
				LightStruct light;
				light.packUV = i.packUV.xy;
				light.normals = i.normals;
				light.eyePosition = i.eyePosition;
				light.lightColor = i.lightColor;
				light.lightDir = i.lightDir;
				light.lightRange = i.lightRange;
				light.lightForward = i.lightForward;
			
				//if (lightType == 2) 
				mainLight = CalculatePointLight(light);
				//mainLight = CalculateSpotLight(i);
				//mainLight = CalculateDirectionalLight(i);
				
				//*** adding light to texture **************************************
				return fixed4 ((mainLight), 1);
			}
			//*********************************************************************************
			
			ENDCG
		}
		
		Pass 
		{
			//Lighting off
			
			Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         	Blend One One // additive blending 
            
			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members n)
			#pragma exclude_renderers xbox360
			
			#pragma glsl
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float4 			_ObjectColor;
			float 			_AmbientInt;
			sampler2D 		_MainTex;
			sampler2D 		_BumpMap;
			
			//light variables
			uniform int 	totalLights;
			uniform int 	lightType;
			//uniform float 	lightType;
			uniform float3 	lightPosition;
			uniform float3 	lightColor;
			uniform float 	lightRange;
			uniform float3	lightDirection;
			uniform float	lightConeAngle;
			uniform float	lightIntensity;
			uniform float	lightFallOffRange = 10;
			
			uniform float4 _LightColor0;
			
			//camera variables
			uniform float3 	cameraPosition;
			
			struct LightStruct
			{
				float2 packUV;
				float3 normals;
				float3 eyePosition;
				float3 lightColor;
				float3 lightDir;
				float lightRange;
				float3 lightForward;
			};
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION;
				float4 packUV 			: TEXCOORD0;
				float3 lightDir 		: TEXCOORD1;
				float3 normals 			: TEXCOORD2;
				float3 eyePosition		: TEXCOORD3;
				float lightRange		: TEXCOORD4;
				float3 lightForward		: TEXCOORD5;
				float3 lightColor		: TEXCOORD6;
				float3 vtang			: TEXCOORD7;
			};
			
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			
			
			//*** custome function ************************************************************
			//function to calculate point light
			float3 CalculatePointLight(LightStruct i)
			{
				fixed2 uv_MainTex = i.packUV.xy;
				
				//*** calculating light color **************************************
				float3 lightColor;
				
				//ambient light
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				lightColor = ambientLighting;
				
				if(i.lightRange > 0)
				{
					//calculate diffuse
					float3 L = normalize(i.lightDir);
					float diffuseInt = max(dot(L, i.normals), 0);
					float3 diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * lightIntensity / i.lightRange;
					
					//specular light
					float3 V = normalize(i.eyePosition);
					float3 H = normalize(L + V);
					float specularInt = pow(max(dot(H, i.normals), 0.0), 2.0);
					float3 specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * lightIntensity / i.lightRange;
					
					//*** getting texture **********************************************
					float3 objTexture = tex2D (_MainTex, uv_MainTex);
					
					//calculate fall off
					lightColor += ((diffuseLighting + specularLighting) * i.lightColor);
				}
				
				return lightColor; //* i.lightColor;
			}
			
			//function to calculate spot light
			float3 CalculateSpotLight(LightStruct i)
			{
				//*** calculate if vertex is within cone of light ******************
				bool withInConeLight = false;
				
				//calculate cone of light
				float dotProduct = dot(normalize(i.lightForward * -1), normalize((i.lightDir)));
				float angleCos = acos(dotProduct);
				float angleToLight = max(angleCos, 0);
				
				if (angleToLight <= lightConeAngle * 0.5) withInConeLight = true;
				
				
				//*** get UVs from vertex ******************************************
				fixed2 uv_MainTex = i.packUV.xy;
				
				//*** getting texture **********************************************
				float3 objTexture = tex2D (_MainTex, uv_MainTex);
				
				//*** calculating light color **************************************
				//ambient light
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				float3 lightColor = ambientLighting;
				
				if (withInConeLight)
				{
					//calculate diffuse
					float3 L = normalize(i.lightDir);
					float diffuseInt = max(dot(L, i.normals), 0);
					float3 diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * lightIntensity / i.lightRange;
					
					//specular light
					float3 V = normalize(i.eyePosition);
					float3 H = normalize(L + V);
					float specularInt = pow(max(dot(H, i.normals), 0.0), 2.0);
					float3 specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * lightIntensity / i.lightRange;
					
					lightColor += (diffuseLighting + specularLighting);
				}
				
				return lightColor * i.lightColor;
			}
			
			//function to calculate directional light
			float3 CalculateDirectionalLight(LightStruct i)
			{
				//*** calculate angle between vertex normal and light direction
				float3 crossProd = cross(normalize(i.normals), normalize(i.lightForward));
				float angleSin = sqrt(crossProd[0] * crossProd[0] + crossProd[1] * crossProd[1] + crossProd[2] * crossProd[2]);
				float angleCos = dot(normalize(i.normals), normalize(i.lightForward));
				
				float directionIntensity = 0;
				
				if (angleCos <= 0) 
				{
					directionIntensity = 1 - angleSin;
				}
				
				//*** get UVs from vertex ******************************************
				fixed2 uv_MainTex = i.packUV.xy;
				
				//*** getting texture **********************************************
				float3 objTexture = tex2D (_MainTex, uv_MainTex);
				
				//*** calculating light color **************************************
				//ambient light
				float ambientNormInt = max(dot(normalize(i.lightDir), i.normals), 0);
				float3 ambientLighting = tex2D (_MainTex, uv_MainTex).xyz * _AmbientInt * ambientNormInt;
				
				//calculate diffuse
				float3 L = normalize(i.lightDir);
				float diffuseInt = max(dot(L, i.normals), 0);
				float3 diffuseLighting = tex2D (_MainTex, uv_MainTex).xyz * diffuseInt * lightIntensity * directionIntensity;
				
				//specular light
				float3 V = normalize(i.eyePosition);
				float3 H = normalize(L + V);
				float specularInt = pow(max(dot(H, i.normals), 0.0), 2.0);
				float3 specularLighting = tex2D (_MainTex, uv_MainTex).xyz * specularInt * lightIntensity * directionIntensity;
				
				float3 lightColor = diffuseLighting + specularLighting + ambientLighting;
				
				return lightColor * i.lightColor;
			}
			//*********************************************************************************
			
			//*** shader functions ************************************************************
			v2f vert (appdata_full v)
			{
				TANGENT_SPACE_ROTATION;
				
				//*** lidhtDirection has been pass as a vector already in object space ***/
				
				//convert camera and light to object space
				cameraPosition = mul(_World2Object, float4 (cameraPosition, 1)).xyz;
				lightPosition = mul(_World2Object, float4 (lightPosition, 1)).xyz;
				
				//*** calculate light direction & distance ***************************
				float3 P = v.vertex.xyz;
				float3 lightDir = lightPosition - P;
				float directMag = sqrt(lightDir[0] * lightDir[0] + lightDir[1] * lightDir[1] + lightDir[2] * lightDir[2]);
				
				
				//rangeDist >= 0 										--> vertex within light range
				//rangeDist < -(lightFallOffRange)						--> vertex outside light range 
				//rangeDist < 0  && rangeDist >= -(lightFallOffRange)	--> vertex outside light range
				
				if (lightFallOffRange > 0) lightFallOffRange *= -1;
				float rangeDist = lightRange - directMag;
				
				if (rangeDist >= 0) lightRange = 1;
				else if (rangeDist <= lightFallOffRange) lightRange = -1;
				else 
				{
					if (rangeDist > -1) lightRange = 1 + abs(rangeDist);
					else lightRange = abs(rangeDist);
				}
				
				//setting output variable
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, float4(P, 1));
				o.vtang = v.tangent;
				o.packUV.xy = TRANSFORM_TEX ((v.texcoord), _MainTex);
				o.packUV.zw = TRANSFORM_TEX ((v.texcoord), _BumpMap);
				o.lightDir = lightDir;
				o.normals = v.normal;
				o.eyePosition = cameraPosition;
				o.lightRange = lightRange;
				o.lightForward = lightDirection;
				
				_ObjectColor = _LightColor0;
				o.lightColor = float3(_ObjectColor.rgb);
				
				return o;	
			}
			
			//pixel shader
			half4 frag (v2f i) : COLOR
			{
				//*** calculating point light color ********************************
				float3 mainLight;
				
				//converting from tangent to object space
				float3 T = normalize(i.vtang);
				float3 N = normalize(i.normals);
				float3 B = normalize(cross(T, N));
				
				float3x3 TBN = transpose(float3x3(T, B, N));
				i.normals = (tex2D(_BumpMap, i.packUV.zw) - 0.5) * 2.0;
				i.normals = normalize(mul(TBN, i.normals));
				
				
				LightStruct light;
				light.packUV = i.packUV.xy;
				light.normals = i.normals;
				light.eyePosition = i.eyePosition;
				light.lightColor = i.lightColor;
				light.lightDir = i.lightDir;
				light.lightRange = i.lightRange;
				light.lightForward = i.lightForward;
			
				//if (lightType == 2) 
				mainLight = CalculatePointLight(light);
				//mainLight = CalculateSpotLight(i);
				//mainLight = CalculateDirectionalLight(i);
				
				//*** adding light to texture **************************************
				return fixed4 ((mainLight), 1);
			}
			//*********************************************************************************
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
} 

