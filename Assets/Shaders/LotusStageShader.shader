// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Lotus/LotusStageShaderStandard"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_AlbedoTint("Albedo Tint", Color) = (1,1,1,0)
		_Normal("Normal", 2D) = "bump" {}
		_NormalMapScale("Normal Map Scale", Range( 0 , 5)) = 1
		[Toggle]_SpecularUseTexture("Specular: Use Texture", Float) = 0
		_SpecularTexture("Specular Texture", 2D) = "gray" {}
		[Toggle]_ColoredSpecular("ColoredSpecular", Float) = 0
		_ColorSpecularPower("Color Specular Power", Range( 0 , 1)) = 0.2
		_DesaturationAmount("Desaturation Amount", Range( 0 , 1)) = 1
		[Toggle]_SmoothnessUseTexture("Smoothness: Use Texture", Float) = 0
		_SmoothnessTexture("Smoothness Texture", 2D) = "gray" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_Emissive("Emissive", 2D) = "black" {}
		_EmissiveStrength("Emissive Strength", Range( 0 , 10)) = 1
		_FresnelStrength("Fresnel Strength", Range( 0 , 1)) = 1
		_DiffuseToEmissiveRatio("Diffuse-To-Emissive-Ratio", Range( 0 , 1)) = 1
		_EmissiveBoost("Emissive Boost", Range( 1 , 10)) = 1
		_EmissiveTint("Emissive Tint", Color) = (1,1,1,0)
		[Toggle]_AddWind("Add Wind", Float) = 0
		_WindSpeed("Wind Speed", Range( 0 , 1)) = 0.1
		_WindNoiseTexture("Wind Noise Texture", 2D) = "black" {}
		_WindStrengthZ("Wind Strength Z", Range( 0 , 10)) = 5
		_WindStrengthY("Wind Strength Y", Range( 0 , 10)) = 5
		_WindStrengthX("Wind Strength X", Range( 0 , 10)) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _AddWind;
		uniform sampler2D _WindNoiseTexture;
		uniform float _WindSpeed;
		uniform float _WindStrengthX;
		uniform float _WindStrengthY;
		uniform float _WindStrengthZ;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalMapScale;
		uniform float _FresnelStrength;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _AlbedoTint;
		uniform float _DiffuseToEmissiveRatio;
		uniform sampler2D _Emissive;
		uniform float4 _Emissive_ST;
		uniform float4 _EmissiveTint;
		uniform float _EmissiveStrength;
		uniform float _EmissiveBoost;
		uniform float _ColoredSpecular;
		uniform float _ColorSpecularPower;
		uniform float _SpecularUseTexture;
		uniform sampler2D _SpecularTexture;
		uniform float4 _SpecularTexture_ST;
		uniform float _DesaturationAmount;
		uniform float _SmoothnessUseTexture;
		uniform float _Smoothness;
		uniform sampler2D _SmoothnessTexture;
		uniform float4 _SmoothnessTexture_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (( _WindSpeed / 100.0 )).xx;
			float2 panner42 = ( 1.0 * _Time.y * temp_cast_0 + v.texcoord.xy);
			float4 tex2DNode43 = tex2Dlod( _WindNoiseTexture, float4( panner42, 0, 0.0) );
			float4 appendResult47 = (float4(tex2DNode43.r , tex2DNode43.g , 0.0 , 0.0));
			float4 appendResult64 = (float4(_WindStrengthX , _WindStrengthY , _WindStrengthZ , 1.0));
			v.vertex.xyz += lerp(float4( 0,0,0,0 ),( appendResult47 * ( appendResult64 / float4( 5000,5000,5000,1 ) ) ),_AddWind).xyz;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalMapScale );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV15 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode15 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV15, 5.0 ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode40 = tex2D( _Albedo, uv_Albedo );
			o.Albedo = ( ( fresnelNode15 * _FresnelStrength ) + ( tex2DNode40 * _AlbedoTint ) ).rgb;
			float2 uv_Emissive = i.uv_texcoord * _Emissive_ST.xy + _Emissive_ST.zw;
			float4 tex2DNode21 = tex2D( _Emissive, uv_Emissive );
			float4 lerpResult34 = lerp( ( tex2DNode40 * _DiffuseToEmissiveRatio ) , ( ( ( tex2DNode21 * tex2DNode21.a ) * _EmissiveTint ) * _EmissiveStrength ) , 0.5);
			o.Emission = ( lerpResult34 * _EmissiveBoost ).rgb;
			float2 uv_SpecularTexture = i.uv_texcoord * _SpecularTexture_ST.xy + _SpecularTexture_ST.zw;
			float3 desaturateInitialColor19 = lerp(tex2D( _Albedo, uv_Albedo ),tex2D( _SpecularTexture, uv_SpecularTexture ),_SpecularUseTexture).rgb;
			float desaturateDot19 = dot( desaturateInitialColor19, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar19 = lerp( desaturateInitialColor19, desaturateDot19.xxx, _DesaturationAmount );
			o.Specular = lerp(( _ColorSpecularPower * lerp(tex2D( _Albedo, uv_Albedo ),tex2D( _SpecularTexture, uv_SpecularTexture ),_SpecularUseTexture) ),float4( desaturateVar19 , 0.0 ),_ColoredSpecular).rgb;
			float4 temp_cast_6 = (_Smoothness).xxxx;
			float2 uv_SmoothnessTexture = i.uv_texcoord * _SmoothnessTexture_ST.xy + _SmoothnessTexture_ST.zw;
			o.Smoothness = lerp(temp_cast_6,tex2D( _SmoothnessTexture, uv_SmoothnessTexture ),_SmoothnessUseTexture).r;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15606
226;92;1128;650;2749.911;896.6707;2.604768;True;False
Node;AmplifyShaderEditor.RangedFloatNode;53;-2112.592,1972.612;Float;False;Property;_WindSpeed;Wind Speed;19;0;Create;True;0;0;False;0;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-2053.406,198.5281;Float;True;Property;_Emissive;Emissive;12;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;58;-1812.475,1981.309;Float;False;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-2005.09,1835.13;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1731.185,236.4651;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;38;-2051.916,394.0954;Float;False;Property;_EmissiveTint;Emissive Tint;17;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;-1549.622,2139.418;Float;False;Property;_WindStrengthX;Wind Strength X;23;0;Create;True;0;0;False;0;5;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1549.622,2229.418;Float;False;Property;_WindStrengthY;Wind Strength Y;22;0;Create;True;0;0;False;0;5;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;42;-1638.659,1836.669;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1541.622,2313.419;Float;False;Property;_WindStrengthZ;Wind Strength Z;21;0;Create;True;0;0;False;0;5;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1551.375,181.9519;Float;False;Property;_DiffuseToEmissiveRatio;Diffuse-To-Emissive-Ratio;15;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-1396.1,1811.944;Float;True;Property;_WindNoiseTexture;Wind Noise Texture;20;0;Create;True;0;0;False;0;16d574e53541bba44a84052fa38778df;16d574e53541bba44a84052fa38778df;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-1666.608,402.6548;Float;False;Property;_EmissiveStrength;Emissive Strength;13;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1540.599,291.0498;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1261.518,2014.151;Float;False;Constant;_0;0;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2138.338,626.0029;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;74;-2133.815,855.2986;Float;True;Property;_SpecularTexture;Specular Texture;5;0;Create;True;0;0;False;0;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;64;-1216.729,2197.332;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;40;-1780.434,-225.9533;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1341.907,319.3855;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;76;-1770.605,-17.10735;Float;False;Property;_AlbedoTint;Albedo Tint;1;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-1475.751,474.1976;Float;False;Constant;_Alpha;Alpha;11;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;-1009.466,2137.896;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;5000,5000,5000,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1223.193,114.8518;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;15;-1185.094,-499.8379;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;47;-1013.337,1933.379;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1718.28,651.2839;Float;False;Property;_ColorSpecularPower;Color Specular Power;7;0;Create;True;0;0;False;0;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1718.472,933.2932;Float;False;Property;_DesaturationAmount;Desaturation Amount;8;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1197.548,-325.6439;Float;False;Property;_FresnelStrength;Fresnel Strength;14;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;67;-1721.205,779.0582;Float;False;Property;_SpecularUseTexture;Specular: Use Texture;4;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-820.3229,2007.492;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-847.7346,137.9544;Float;False;Property;_NormalMapScale;Normal Map Scale;3;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;19;-1312.095,865.0353;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1292.908,659.0219;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;34;-1030.84,278.7199;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1255.173,-194.0307;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;65;-1412.5,1134.687;Float;True;Property;_SmoothnessTexture;Smoothness Texture;10;0;Create;True;0;0;False;0;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-1392.869,1045.346;Float;False;Property;_Smoothness;Smoothness;11;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-854.3476,-52.13988;Float;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-889.9155,-424.6472;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1056.07,419.9424;Float;False;Property;_EmissiveBoost;Emissive Boost;16;0;Create;True;0;0;False;0;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;66;-1055.539,1094.333;Float;False;Property;_SmoothnessUseTexture;Smoothness: Use Texture;9;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;18;-1056.771,763.2122;Float;False;Property;_ColoredSpecular;ColoredSpecular;6;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;50;-607.6127,1947.849;Float;False;Property;_AddWind;Add Wind;18;0;Create;True;0;0;False;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-740.6691,327.5747;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;13;-507.2938,32.56124;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-708.3237,-337.0595;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1.6,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;Lotus/LotusStageShaderStandard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;58;0;53;0
WireConnection;24;0;21;0
WireConnection;24;1;21;4
WireConnection;42;0;41;0
WireConnection;42;2;58;0
WireConnection;43;1;42;0
WireConnection;39;0;24;0
WireConnection;39;1;38;0
WireConnection;64;0;61;0
WireConnection;64;1;62;0
WireConnection;64;2;63;0
WireConnection;26;0;39;0
WireConnection;26;1;27;0
WireConnection;57;0;64;0
WireConnection;33;0;40;0
WireConnection;33;1;32;0
WireConnection;47;0;43;1
WireConnection;47;1;43;2
WireConnection;47;2;54;0
WireConnection;67;0;1;0
WireConnection;67;1;74;0
WireConnection;49;0;47;0
WireConnection;49;1;57;0
WireConnection;19;0;67;0
WireConnection;19;1;20;0
WireConnection;10;0;11;0
WireConnection;10;1;67;0
WireConnection;34;0;33;0
WireConnection;34;1;26;0
WireConnection;34;2;35;0
WireConnection;77;0;40;0
WireConnection;77;1;76;0
WireConnection;30;0;15;0
WireConnection;30;1;31;0
WireConnection;66;0;17;0
WireConnection;66;1;65;0
WireConnection;18;0;10;0
WireConnection;18;1;19;0
WireConnection;50;1;49;0
WireConnection;36;0;34;0
WireConnection;36;1;37;0
WireConnection;13;0;2;0
WireConnection;13;1;14;0
WireConnection;29;0;30;0
WireConnection;29;1;77;0
WireConnection;0;0;29;0
WireConnection;0;1;13;0
WireConnection;0;2;36;0
WireConnection;0;3;18;0
WireConnection;0;4;66;0
WireConnection;0;11;50;0
ASEEND*/
//CHKSM=5E4256CB47CE590C96C8430026C90D641A12DFAF