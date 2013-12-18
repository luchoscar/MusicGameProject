Shader "Custom/Simple Tess PN" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_TessEdge ("Tessellation", Range(1,16)) = 2
	}
	
	SubShader 
	{
		Pass 
		{
			Tags {"LightMode" = "Vertex"}
			
			CGPROGRAM
			#pragma target 5.0
			
			//#pragma vertex VS_RenderScene
			//#pragma fragment PS_RenderSceneTextured
			
			#pragma vertex VS_RenderSceneWithTessellation
			#pragma fragment PS_RenderSceneTextured
			#pragma hull HS_PNTriangles
			#pragma domain DS_PNTriangles
			
			#include "UnityCG.cginc"
			
			float _TessEdge;
			float _TessInside;
			
			
			//================================================== ================================================== =============================
			// Buffers, Textures and Samplers
			//================================================== ================================================== =============================
			
			Texture2D _MainTex;
			SamplerState	sampler_MainTex;
			
			//================================================== ================================================== =============================
			// Shader structures
			//================================================== ================================================== =============================
			
			
			struct VS_RenderSceneInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};
			
			struct HS_Input
			{
				float4 f4Position : POS;
				float3 f3Normal : NORMAL;
				float2 f2TexCoord : TEXCOORD;
			};
			
			struct HS_ConstantOutput
			{
				// Tess factor for the FF HW block
				float fTessFactor[3] : SV_TessFactor;
				float fInsideTessFactor : SV_InsideTessFactor;
				
				// Geometry cubic generated control points
				float3 f3B210 : POS3;
				float3 f3B120 : POS4;
				float3 f3B021 : POS5;
				float3 f3B012 : POS6;
				float3 f3B102 : POS7;
				float3 f3B201 : POS8;
				float3 f3B111 : CENTER;
				
				// Normal quadratic generated control points
				float3 f3N110 : NORMAL3; 
				float3 f3N011 : NORMAL4;
				float3 f3N101 : NORMAL5;
			};
			
			struct HS_ControlPointOutput
			{
				float3 f3Position : POS;
				float3 f3Normal : NORMAL;
				float2 f2TexCoord : TEXCOORD;
			};
			
			struct DS_Output
			{
				float4 f4Position : SV_Position;
				float2 f2TexCoord : TEXCOORD0; 
				float4 f4Diffuse : COLOR0;
			};
			
			struct PS_RenderSceneInput
			{
				float4 f4Position : SV_Position;
				float2 f2TexCoord : TEXCOORD0;
				float4 f4Diffuse : COLOR0;
			};
			
			struct PS_RenderOutput
			{
				float4 f4Color : SV_Target0;
			};
			
//			PS_RenderSceneInput VS_RenderScene( VS_RenderSceneInput I )
//			{
//				PS_RenderSceneInput O;
//				
//				O.f4Position = mul (UNITY_MATRIX_MVP, float4(I.vertex, 1.0f));
//				float3 viewN = mul ((float3x3)UNITY_MATRIX_IT_MV, I.normal);
//				
//				// Calc diffuse color 
//				O.f4Diffuse.rgb = unity_LightColor[0].rgb * max(0, dot(viewN, unity_LightPosition[0].xyz)) + UNITY_LIGHTMODEL_AMBIENT.rgb;
//				O.f4Diffuse.a = 1.0f;
//				
//				// Pass through texture coords
//				O.f2TexCoord = I.texcoord; 
//				
//				return O; 
//			}
				
				
			HS_Input VS_RenderSceneWithTessellation( VS_RenderSceneInput I )
			{
				HS_Input O;
				
				// To view space
				O.f4Position = mul(UNITY_MATRIX_MV, float4(I.vertex,1.0f));
				O.f3Normal = mul ((float3x3)UNITY_MATRIX_IT_MV, I.normal);
				
				O.f2TexCoord = I.texcoord;
				
				return O;
			}
			
			
			//================================================== ================================================== =============================
			// This hull shader passes the tessellation factors through to the HW tessellator, 
			// and the 10 (geometry), 6 (normal) control points of the PN-triangular patch to the domain shader
			//================================================== ================================================== =============================
			HS_ConstantOutput HS_PNTrianglesConstant( InputPatch<HS_Input, 3> I )
			{
				HS_ConstantOutput O = (HS_ConstantOutput)0;
			
				// Simply output the tessellation factors from constant space 
				// for use by the FF tessellation unit
				O.fTessFactor[0] = O.fTessFactor[1] = O.fTessFactor[2] = _TessEdge;
				O.fInsideTessFactor = _TessEdge;
				
				// Assign Positions
				float3 f3B003 = I[0].f4Position.xyz;
				float3 f3B030 = I[1].f4Position.xyz;
				float3 f3B300 = I[2].f4Position.xyz;
				// And Normals
				float3 f3N002 = I[0].f3Normal;
				float3 f3N020 = I[1].f3Normal;
				float3 f3N200 = I[2].f3Normal;
				
				// Compute the cubic geometry control points
				// Edge control points
				O.f3B210 = ( ( 2.0f * f3B003 ) + f3B030 - ( dot( ( f3B030 - f3B003 ), f3N002 ) * f3N002 ) ) / 3.0f;
				O.f3B120 = ( ( 2.0f * f3B030 ) + f3B003 - ( dot( ( f3B003 - f3B030 ), f3N020 ) * f3N020 ) ) / 3.0f;
				O.f3B021 = ( ( 2.0f * f3B030 ) + f3B300 - ( dot( ( f3B300 - f3B030 ), f3N020 ) * f3N020 ) ) / 3.0f;
				O.f3B012 = ( ( 2.0f * f3B300 ) + f3B030 - ( dot( ( f3B030 - f3B300 ), f3N200 ) * f3N200 ) ) / 3.0f;
				O.f3B102 = ( ( 2.0f * f3B300 ) + f3B003 - ( dot( ( f3B003 - f3B300 ), f3N200 ) * f3N200 ) ) / 3.0f;
				O.f3B201 = ( ( 2.0f * f3B003 ) + f3B300 - ( dot( ( f3B300 - f3B003 ), f3N002 ) * f3N002 ) ) / 3.0f;
				// Center control point
				float3 f3E = ( O.f3B210 + O.f3B120 + O.f3B021 + O.f3B012 + O.f3B102 + O.f3B201 ) / 6.0f;
				float3 f3V = ( f3B003 + f3B030 + f3B300 ) / 3.0f;
				O.f3B111 = f3E + ( ( f3E - f3V ) / 2.0f );
				
				// Compute the quadratic normal control points
				float fV12 = 2.0f * dot( f3B030 - f3B003, f3N002 + f3N020 ) / dot( f3B030 - f3B003, f3B030 - f3B003 );
				O.f3N110 = normalize( f3N002 + f3N020 - fV12 * ( f3B030 - f3B003 ) );
				float fV23 = 2.0f * dot( f3B300 - f3B030, f3N020 + f3N200 ) / dot( f3B300 - f3B030, f3B300 - f3B030 );
				O.f3N011 = normalize( f3N020 + f3N200 - fV23 * ( f3B300 - f3B030 ) );
				float fV31 = 2.0f * dot( f3B003 - f3B300, f3N200 + f3N002 ) / dot( f3B003 - f3B300, f3B003 - f3B300 );
				O.f3N101 = normalize( f3N200 + f3N002 - fV31 * ( f3B003 - f3B300 ) );
				
				return O;
			}
			
			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("HS_PNTrianglesConstant")]
			[outputcontrolpoints(3)]
			HS_ControlPointOutput HS_PNTriangles( InputPatch<HS_Input, 3> I, uint uCPID : SV_OutputControlPointID )
			{
				HS_ControlPointOutput O = (HS_ControlPointOutput)0;
				
				// Just pass through inputs = fast pass through mode triggered
				O.f3Position = I[uCPID].f4Position.xyz;
				O.f3Normal = I[uCPID].f3Normal;
				O.f2TexCoord = I[uCPID].f2TexCoord;
				
				return O;
			}
			
			
			//================================================== ================================================== =============================
			// This domain shader applies contol point weighting to the barycentric coords produced by the FF tessellator 
			//================================================== ================================================== =============================
			[domain("tri")]
			DS_Output DS_PNTriangles( HS_ConstantOutput HSConstantData, const OutputPatch<HS_ControlPointOutput, 3> I, float3 f3BarycentricCoords : SV_DomainLocation )
			{
				DS_Output O = (DS_Output)0;
				
				// The barycentric coordinates
				float fU = f3BarycentricCoords.x;
				float fV = f3BarycentricCoords.y;
				float fW = f3BarycentricCoords.z;
				
				// Precompute squares and squares * 3 
				float fUU = fU * fU;
				float fVV = fV * fV;
				float fWW = fW * fW;
				float fUU3 = fUU * 3.0f;
				float fVV3 = fVV * 3.0f;
				float fWW3 = fWW * 3.0f;
				
				// Compute position from cubic control points and barycentric coords
				float3 f3Position = I[0].f3Position * fWW * fW +
				I[1].f3Position * fUU * fU +
				I[2].f3Position * fVV * fV +
				HSConstantData.f3B210 * fWW3 * fU +
				HSConstantData.f3B120 * fW * fUU3 +
				HSConstantData.f3B201 * fWW3 * fV +
				HSConstantData.f3B021 * fUU3 * fV +
				HSConstantData.f3B102 * fW * fVV3 +
				HSConstantData.f3B012 * fU * fVV3 +
				HSConstantData.f3B111 * 6.0f * fW * fU * fV;
				
				// Compute normal from quadratic control points and barycentric coords
				float3 f3Normal = I[0].f3Normal * fWW +
				I[1].f3Normal * fUU +
				I[2].f3Normal * fVV +
				HSConstantData.f3N110 * fW * fU +
				HSConstantData.f3N011 * fU * fV +
				HSConstantData.f3N101 * fW * fV;
				
				// Normalize the interpolated normal 
				f3Normal = normalize( f3Normal );
				
				// Linearly interpolate the texture coords
				O.f2TexCoord = I[0].f2TexCoord * fW + I[1].f2TexCoord * fU + I[2].f2TexCoord * fV;
				
				// Calc diffuse color 
				O.f4Diffuse.rgb = unity_LightColor[0].rgb * max( 0, dot( f3Normal, unity_LightPosition[0].xyz ) ) + UNITY_LIGHTMODEL_AMBIENT.rgb;
				O.f4Diffuse.a = 1.0f;
				//O.f4Diffuse.rgb = f3BarycentricCoords;
				
				// Transform position with projection matrix
				O.f4Position = mul (UNITY_MATRIX_P, float4(f3Position.xyz,1.0));
				
				return O;
			}
			
			
			PS_RenderOutput PS_RenderSceneTextured( PS_RenderSceneInput I )
			{
				PS_RenderOutput O;
				
				O.f4Color = _MainTex.Sample( sampler_MainTex, I.f2TexCoord ) * I.f4Diffuse;
				
				return O;
			}
			
			ENDCG
		
		}
	}
	
	Fallback "VertexLit"
}