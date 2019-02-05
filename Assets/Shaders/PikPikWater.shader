// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX/PikPikWater"
{
	Properties
	{
		_WaterBaseColor("WaterBaseColor", Color) = (0.07450981,0.4666667,0.7411765,0)
		_WaterReflectiveColor("WaterReflectiveColor", Color) = (0.254902,0.7098039,0.8588236,0)
		_WaterBump("WaterBump", 2D) = "bump" {}
		_NormalScale("NormalScale", Range( 0 , 5)) = 1
		_TextureScale1("TextureScale1", Range( 0 , 100)) = 4.4
		_TextureScale2("TextureScale2", Range( 0 , 100)) = 1.8
		_WaveDirection2("WaveDirection2", Vector) = (-0.0025,-0.005,0,0)
		_WaveDirection1("WaveDirection1", Vector) = (0.005,0.0025,0,0)
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_Specular("Specular", Range( 0 , 1)) = 0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _WaterBump;
		uniform float2 _WaveDirection1;
		uniform float _TextureScale1;
		uniform float2 _WaveDirection2;
		uniform float _TextureScale2;
		uniform float _NormalScale;
		uniform float4 _WaterBaseColor;
		uniform float4 _WaterReflectiveColor;
		uniform float _Specular;
		uniform float _Opacity;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult27 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 temp_output_45_0 = ( abs( appendResult27 ) + float4( 1,1,1,1 ) );
			float2 uv_TexCoord8 = i.uv_texcoord * ( temp_output_45_0 / _TextureScale1 ).xy;
			float2 panner6 = ( 1.0 * _Time.y * _WaveDirection1 + uv_TexCoord8);
			float2 uv_TexCoord29 = i.uv_texcoord * ( temp_output_45_0 / _TextureScale2 ).xy;
			float2 panner10 = ( 1.0 * _Time.y * _WaveDirection2 + uv_TexCoord29);
			float4 lerpResult13 = lerp( tex2D( _WaterBump, panner6 ) , tex2D( _WaterBump, panner10 ) , 0.4980392);
			o.Normal = UnpackScaleNormal( lerpResult13, _NormalScale );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV2 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode2 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV2, 5.0 ) );
			float4 lerpResult3 = lerp( _WaterBaseColor , _WaterReflectiveColor , fresnelNode2);
			o.Albedo = lerpResult3.rgb;
			float3 temp_cast_4 = (_Specular).xxx;
			o.Specular = temp_cast_4;
			o.Smoothness = 1.0;
			float clampResult39 = clamp( ( ( _Opacity * ( (lerpResult13).b + 1.0 ) ) / 2.0 ) , ( _Opacity * _Opacity ) , _Opacity );
			o.Alpha = clampResult39;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

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
			sampler3D _DitherMaskLOD;
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
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
244;92;1222;650;1096.571;-154.7731;1.06881;False;False
Node;AmplifyShaderEditor.WorldPosInputsNode;24;-3603.578,222.1358;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;27;-3373.375,252.3628;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;44;-3220.189,261.5077;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-3039.149,286.5573;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;1,1,1,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2851.677,141.1104;Float;False;Property;_TextureScale1;TextureScale1;4;0;Create;True;0;0;False;0;4.4;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2794.984,457.5899;Float;False;Property;_TextureScale2;TextureScale2;5;0;Create;True;0;0;False;0;1.8;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-2574.984,387.5899;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-2578.677,162.5105;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;28;-2362.461,599.4843;Float;False;Property;_WaveDirection2;WaveDirection2;6;0;Create;True;0;0;False;0;-0.0025,-0.005;0.2,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-2401.749,149.512;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;7;-2398.655,279.6059;Float;False;Property;_WaveDirection1;WaveDirection1;7;0;Create;True;0;0;False;0;0.005,0.0025;0.2,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2370.461,456.4843;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;10;-2039.797,462.7963;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;6;-2064.749,176.512;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1799.238,149.2727;Float;True;Property;_WaterBump;WaterBump;2;0;Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-1788.343,401.9049;Float;True;Property;_WaterBump;WaterBump;2;0;Fetch;False;0;0;False;0;None;None;True;0;True;bump;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;13;-1361.568,352.5739;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.4980392;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;34;-1158.136,402.261;Float;False;False;False;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-947.1744,430.2284;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1114.408,539.1017;Float;False;Property;_Opacity;Opacity;8;0;Create;True;0;0;False;0;1;0.7;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-780.8684,404.3105;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-623.2012,420.5092;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-772.8292,604.0623;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;2;-892.4872,-115.5221;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-882.03,-463.1838;Float;False;Property;_WaterBaseColor;WaterBaseColor;0;0;Create;True;0;0;False;0;0.07450981,0.4666667,0.7411765,0;0,0.3960955,0.7867647,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-1154.337,173.7154;Float;False;Property;_NormalScale;NormalScale;3;0;Create;True;0;0;False;0;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-894.03,-295.1838;Float;False;Property;_WaterReflectiveColor;WaterReflectiveColor;1;0;Create;True;0;0;False;0;0.254902,0.7098039,0.8588236,0;0.04163061,0.8088235,0.4913644,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;39;-472.0122,473.4247;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-521.9124,191.3731;Float;False;Property;_Specular;Specular;9;0;Create;True;0;0;False;0;0.3;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-520.9124,284.3731;Float;False;Constant;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;3;-499.4872,-194.5221;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;55;-816.3361,146.4153;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-7.559377,47.51608;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;FX/PikPikWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;True;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;24;1
WireConnection;27;1;24;3
WireConnection;44;0;27;0
WireConnection;45;0;44;0
WireConnection;31;0;45;0
WireConnection;31;1;30;0
WireConnection;25;0;45;0
WireConnection;25;1;26;0
WireConnection;8;0;25;0
WireConnection;29;0;31;0
WireConnection;10;0;29;0
WireConnection;10;2;28;0
WireConnection;6;0;8;0
WireConnection;6;2;7;0
WireConnection;1;1;6;0
WireConnection;21;1;10;0
WireConnection;13;0;1;0
WireConnection;13;1;21;0
WireConnection;34;0;13;0
WireConnection;36;0;34;0
WireConnection;37;0;16;0
WireConnection;37;1;36;0
WireConnection;38;0;37;0
WireConnection;40;0;16;0
WireConnection;40;1;16;0
WireConnection;39;0;38;0
WireConnection;39;1;40;0
WireConnection;39;2;16;0
WireConnection;3;0;19;0
WireConnection;3;1;18;0
WireConnection;3;2;2;0
WireConnection;55;0;13;0
WireConnection;55;1;56;0
WireConnection;0;0;3;0
WireConnection;0;1;55;0
WireConnection;0;3;50;0
WireConnection;0;4;53;0
WireConnection;0;9;39;0
ASEEND*/
//CHKSM=A59FE427A24767D6F80BFA2BBF036718A4C1A187