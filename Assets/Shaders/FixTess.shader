Shader "Custom/FixTess"
{
        Properties {
            _Tess ("Tessellation", Range(1,32)) = 4
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _DispTex ("Disp Texture", 2D) = "gray" {}
            _NormalMap ("Normalmap", 2D) = "bump" {}
            _Displacement ("Displacement", Range(0, 1.0)) = 0.3
            _Color ("Color", color) = (1,1,1,0)
            _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300

            CGPROGRAM
            //#pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap
            #pragma target 5.0
		
            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            float _Tess;

            float4 tessFixed()
            {
                return _Tess;
            }
			
            sampler2D _DispTex;
            float _Displacement;
			uniform float3 playerPos;
			uniform float3 playerFwd;
			
//			struct v2f 
//			{
//				float4 v_pos : SV_POSITION;
//				float2 uv_MainTex : TEXCOORD0;
//				float disp : TEXCOORD1;
//			}
			
            void disp (inout appdata v)
            //void disp (inout appdata v, out v2f o;)
            {
                float d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
                //v.vertex.xyz += v.normal * d;
                
                TANGENT_SPACE_ROTATION;
//				
				float3 p = v.vertex.xyz;
				playerPos = mul(_World2Object, float4(playerPos, 1)).xyz;
				playerPos[1] = p[1];
				playerFwd[1] = p[1];
				
//				
				playerFwd = normalize(playerFwd);
//				
				float maxAngle = 3.1416 * 3 * 0.5;	// 3 * PI / 2
				float3 dist = p - playerPos;
				float disp = 0.0;
				if (length(dist) <= maxAngle)
				{
					maxAngle += dist;
					
					float dotProd = max(dot(playerFwd, normalize(dist)), 0);
					//v.vertex.y += sin(maxAngle) * dotProd;
					disp += sin(maxAngle) * dotProd;
				}
//				
				//v2f o;
//				o.v_pos = v.vertex;
//				o.uv_MainTex = v.texcoord;
//				o.disp = disp;
				//return o;
				v.vertex.y += disp;
            }

            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) {
            //void surf (v2f IN, inout SurfaceOutput o) {
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }