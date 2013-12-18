Shader "Custom/CustomTess" 
{	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }

	}
	
	SubShader 
	{
		Pass 
		{
			//Lighting off
			
			CGPROGRAM
			#pragma exclude_renderers xbox360
			#pragma target 5.0
			#pragma vertex vert
			#pragma hull hull
			#pragma domain domain
			#pragma fragment frag
			
			#include "HLSLSupport.cginc"
			#include "UnityCG.cginc"
						
			sampler2D _MainTex;
			
			//vertex shader
			struct v2f 
			{
				float4 pos 				: SV_POSITION; 
//				float4 pos 				: SV_POSITION;
				float2 packUV			: TEXCOORD0;
//				float3 normals			: NORMAL;
//				float3 tangents			: TANGENT;
				
			};
			
			//vertex shader
			struct v2fa
			{
//				float4 pos 				: POSITION; 
				float4 pos 				: SV_POSITION;
				float2 packUV			: TEXCOORD0;
//				float3 normals			: NORMAL;
//				float3 tangents			: TANGENT;
				
			};
						
			float4 _MainTex_ST;
			
			//vertex shader
			
			struct appdata {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};
			
			//v2f vert (appdata vet)
			v2f vert (void)
//			v2f vert (appdata_full v)
			{
//				TANGENT_SPACE_ROTATION;
				
				//*** calculate light direction & distance ***************************
//				float3 P = v.vertex.xyz;
				
				v2f o;
				//o.pos = mul (UNITY_MATRIX_MVP, vet.vertex);
				o.pos = mul (UNITY_MATRIX_MVP, float4(0,0,0,1);
//				o.packUV = TRANSFORM_TEX ((v.texcoord), _MainTex);
				o.packUV = vet.texcoord;
//				o.normals = v.normal;
//				o.tangents = v.tangent;
				
				return o;	
			}
			
			//hull shader
			
			struct HS_CONSTANT_OUTPUT
			{
//				float edges[4]  : SV_TessFactor;
//				float inside[2] : SV_InsideTessFactor;
				float edges[3]  : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};
			
			//consta output --> patch = quad there fore  4 points, 4 outter tess const, 2 inner tess const
			HS_CONSTANT_OUTPUT HSConstant( InputPatch<v2fa, 4> ip, uint pid : SV_PrimitiveID )
			{
				HS_CONSTANT_OUTPUT output;
				
				float edge = 32.0f;
				float inside = 32.0f;
				
				output.edges[0] = edge;
				output.edges[1] = edge;
				output.edges[2] = edge;
				output.edges[3] = edge;
				
				output.inside[0] = inside;
				output.inside[1] = inside;
				output.inside = inside;
				
				return output;
			}
			
			[domain("quad")]
			//[domain("tri")]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[outputcontrolpoints(4)]
			//[outputcontrolpoints(3)]
			[patchconstantfunc("HSConstant")]
			
			v2f hull( InputPatch<v2fa, 4> ip, uint cpid : SV_OutputControlPointID, uint pid : SV_PrimitiveID )
			//v2f hull( InputPatch<v2fa, 3> ip, uint cpid : SV_OutputControlPointID, uint pid : SV_PrimitiveID )
			{
//				v2f Output;
				//Output.pos = ip[cpid].position;	//redefine position as it has been converted by MVP matrix
//				Output.pos = ip[cpid].pos;	//redefine position as it has been converted by MVP matrix
//				return Output;

				return ip[cpid];
			}
			
			//domain shader
			[domain("quad")]
			//[domain("tri")]
			v2f domain( HS_CONSTANT_OUTPUT input, float2 UV : SV_DomainLocation, const OutputPatch<v2fa, 4> patch )
			//v2f domain( HS_CONSTANT_OUTPUT input, float2 UV : SV_DomainLocation, const OutputPatch<v2fa, 3> patch )
			{
//				float3 topMidpoint = lerp(patch[0].position, patch[1].position, UV.x);
//				float3 bottomMidpoint = lerp(patch[3].position, patch[2].position, UV.x);
//				
//				float2 uvtopMidpoint = lerp(patch[0].texcoord, patch[1].texcoord, UV.x);
//				float2 uvbottomMidpoint = lerp(patch[3].texcoord, patch[2].texcoord, UV.x);
				
				float3 topMidpoint = lerp(patch[0].pos, patch[1].pos, UV.x);
				float3 bottomMidpoint = lerp(patch[3].pos, patch[2].pos, UV.x);
				
				float2 uvtopMidpoint = lerp(patch[0].packUV, patch[1].packUV, UV.x);
				float2 uvbottomMidpoint = lerp(patch[3].packUV, patch[2].packUV, UV.x);
				
				//TANGENT_SPACE_ROTATION;
				v2f o;
				o.pos = float4(lerp(topMidpoint, bottomMidpoint, UV.y), 1);
				o.packUV = lerp(uvtopMidpoint, uvbottomMidpoint, UV.y);
				//o.packUV = TRANSFORM_TEX(o.packUV, _MainTex);
				//o.packUV = float2(0,0);
				return o;
			}
			
			//pixel shader
			half4 frag (v2f i) : COLOR
			{
				float2 uv_MainTex = i.packUV;
				
				//*** calculating point light color ********************************
				float3 textColor = tex2D (_MainTex, uv_MainTex).xyz;

				
				return fixed4 ((textColor), 1);
			}
			//*********************************************************************************
			
			ENDCG
		}
	}
	
	Fallback "Diffuse"
} 