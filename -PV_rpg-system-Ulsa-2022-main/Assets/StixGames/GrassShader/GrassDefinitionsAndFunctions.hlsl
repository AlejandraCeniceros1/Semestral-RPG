#ifndef GRASS_DEFINITIONS
#define GRASS_DEFINITIONS

// ================= PRECOMPILER HELPERS ============
#if defined(GRASS_USE_TEXTURE_ATLAS) && !defined(SIMPLE_GRASS)
	#define GRASS_TEXTURE_ATLAS
#endif

// ================================== VARIABLES ================================
sampler2D _ColorMap;
half _TargetDensity;
half _DensityFalloffStart;
half _DensityFalloffScale;
half _DensityFalloffPower;

#ifdef GRASS_FALLBACK_RENDERER
int _TargetTessellation;
#endif

half _LODStart;
half _LODEnd;
int   _LODMax;

half _GrassFadeStart;
half _GrassFadeEnd;

half4 _GrassFloorColor;
sampler2D _GrassFloorColorTexture;
half _FloorColorStrength;
half _FloorColorPower;
half _FloorColorOffset;

half _BurnCutoff;

//Wind
#if defined(GRASS_CALC_GLOBAL_WIND)
	half4 _WindParams;
	half _WindRotation;
#endif

#ifdef GRASS_INTERACTION
	#ifdef GRASS_RENDERTEXTURE_INTERACTION
		sampler2D _GrassRenderTextureInteraction;
		sampler2D _GrassRenderTextureBurn;

		//This is the area the grass interaction camera is currently rendering. xy is left bottom, wz is width and height.
		float4 _GrassRenderTextureArea;
	#else
		sampler2D _Displacement;
	#endif
#endif

//Density for the geom shader. "density" is the sampled texture from _Density.
#ifdef UNIFORM_DENSITY
	half4 _DensityValues;
	#define DENSITY00 _DensityValues.x
	#define DENSITY01 _DensityValues.y
	#define DENSITY02 _DensityValues.z
	#define DENSITY03 _DensityValues.w
#else
	#ifndef VERTEX_DENSITY
		sampler2D _DensityTexture;
	#endif
	#define DENSITY00 density.r
	#define DENSITY01 density.g
	#define DENSITY02 density.b
	#define DENSITY03 density.a
#endif

#if !defined(SIMPLE_GRASS)
	float _TextureCutoff;

	sampler2D _GrassTex00;
#endif
#ifndef GRASS_PASS_SHADOWCASTER
	half4 _Color00;
	half4 _SecColor00;
	half3 _SpecColor00;
	half _Smoothness00;
	half _Subsurface00;
#endif
half _MaxHeight00;
half _Softness00;
half _Weight00;
half _Width00;
half _MinHeight00;
half _AtlasOffset00;
#ifdef GRASS_TEXTURE_ATLAS
	int _TextureAtlasWidth00;
	int _TextureAtlasHeight00;
#endif

#if !defined(SIMPLE_GRASS) && !defined(ONE_GRASS_TYPE)
	sampler2D _GrassTex01;
	#ifndef GRASS_PASS_SHADOWCASTER
		half4 _Color01;
		half4 _SecColor01;
		half3 _SpecColor01;
		half _Smoothness01;
		half _Subsurface01;
	#endif
	half _MaxHeight01;
	half _Softness01;
	half _Weight01;
	half _Width01;
	half _MinHeight01;
	half _AtlasOffset01;
	#ifdef GRASS_TEXTURE_ATLAS
		int _TextureAtlasWidth01;
		int _TextureAtlasHeight01;
	#endif
#endif

#if !defined(SIMPLE_GRASS) && !defined(ONE_GRASS_TYPE) && !defined(TWO_GRASS_TYPES)
	sampler2D _GrassTex02;
	#ifndef GRASS_PASS_SHADOWCASTER
		half4 _Color02;
		half4 _SecColor02;
		half3 _SpecColor02;
		half _Smoothness02;
		half _Subsurface02;
	#endif
	half _MaxHeight02;
	half _Softness02;
	half _Weight02;
	half _Width02;
	half _MinHeight02;
	half _AtlasOffset02;
	#ifdef GRASS_TEXTURE_ATLAS
		int _TextureAtlasWidth02;
		int _TextureAtlasHeight02;
	#endif
#endif

#if !defined(SIMPLE_GRASS) && !defined(ONE_GRASS_TYPE) && !defined(TWO_GRASS_TYPES) && !defined(THREE_GRASS_TYPES)
	sampler2D _GrassTex03;
	#ifndef GRASS_PASS_SHADOWCASTER
		half4 _Color03;
		half4 _SecColor03;
		half3 _SpecColor03;
		half _Smoothness03;
		half _Subsurface03;
	#endif
	half _MaxHeight03;
	half _Softness03;
	half _Weight03;
	half _Width03;
	half _MinHeight03;
	half _AtlasOffset03;
	#ifdef GRASS_TEXTURE_ATLAS
		int _TextureAtlasWidth03;
		int _TextureAtlasHeight03;
	#endif
#endif

half _Disorder;

//Scaling and offset for _DensityTexture
float4 _DensityTexture_ST;

// ================================= STRUCTS ===================================
struct appdata 
{
	float4 vertex : POSITION;

    #ifdef VERTEX_DENSITY
		half4 color : COLOR;
	#endif

	#if defined(GRASS_FOLLOW_SURFACE_NORMAL) || defined(GRASS_SURFACE_NORMAL_LIGHTING) || defined(GRASS_HYBRID_NORMAL_LIGHTING)
		float3 normal : NORMAL;
	#endif

	float2 uv : TEXCOORD0;
	//TODO: Add lightmapping, see UnityStandardCore.cginc line 303
	/*float2 uv1 : TEXCOORD1;
	#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
		float2 uv2 : TEXCOORD2;
	#endif*/
};

struct tess_appdata 
{
	float4 vertex : INTERNALTESSPOS;

	#ifdef VERTEX_DENSITY
		half4 color : COLOR;
	#endif

	#if defined(GRASS_FOLLOW_SURFACE_NORMAL) || defined(GRASS_SURFACE_NORMAL_LIGHTING) || defined(GRASS_HYBRID_NORMAL_LIGHTING)
		float3 normal : NORMAL;
	#endif

	float2 uv : TEXCOORD0;
	float3 cameraPos : TEXCOORD1;

	#ifdef GRASS_OBJECT_MODE
		float3 objectSpacePos : TEXCOORD2;
	#endif
};

struct HS_CONSTANT_OUTPUT
{
	half edges[3]  : SV_TessFactor;
	half inside : SV_InsideTessFactor;
	half realTess : REALTESS;
	half mTess : MEANTESS;
};

struct GS_INPUT
{
	float4 position : SV_POSITION;

	#ifdef VERTEX_DENSITY
		half4 color : COLOR;
	#endif

	#if defined(GRASS_FOLLOW_SURFACE_NORMAL) || defined(GRASS_SURFACE_NORMAL_LIGHTING) || defined(GRASS_HYBRID_NORMAL_LIGHTING)
		float3 normal : NORMAL;
	#endif

	float2 uv : TEXCOORD0;
	float3 cameraPos : TEXCOORD1;

	#if defined(GRASS_HEIGHT_SMOOTHING) || defined(GRASS_WIDTH_SMOOTHING) || defined(GRASS_ALPHA_SMOOTHING)
		half smoothing : TANGENT2;
	#endif

	#ifdef GRASS_OBJECT_MODE
		float3 objectSpacePos : TEXCOORD3;
	#endif
};

struct GS_OUTPUT {
	float4 vertex : SV_POSITION;
	half3 normal : NORMAL;
	
	#if defined(GRASS_HYBRID_NORMAL_LIGHTING)
		half3 specularNormal : NORMAL1;
	#endif

	#if !defined(SIMPLE_GRASS)
		half2 uv  : TEXCOORD0;
		int texIndex : TEXCOORD1;

		#ifdef GRASS_TEXTURE_ATLAS
			int textureAtlasIndex : TEXCOORD2;
		#endif
	#endif

	half4 color : COLOR;
	half4 floorColor : TEXCOORD3;
};

struct FS_INPUT
{
	float3 worldPos : TEXCOORD7;

	half4 color : COLOR;
	half4 floorColor : TEXCOORD8;

	#if !defined(GRASS_PASS_SHADOWCASTER)
		float4  pos : SV_POSITION;
		half3 normal : NORMAL;
		
		#if !defined GRASS_HDRP
            #if defined(GRASS_HYBRID_NORMAL_LIGHTING)
                half3 specularNormal : NORMAL1;
            #endif
    
            #if UNITY_SHOULD_SAMPLE_SH
                half3 sh : TANGENT;
            #endif
            SHADOW_COORDS(4)
            UNITY_FOG_COORDS(5)
            float4 ambientOrLightmapUV : TEXCOORD6;
        #endif
	#else
	    #if defined(GRASS_URP) || defined(GRASS_HDRP)
	        float4  pos : SV_POSITION;
	    #else
	        V2F_SHADOW_CASTER;
	    #endif
	#endif
		
	#if !defined(SIMPLE_GRASS)
		half2 uv : TEXCOORD2;
		int texIndex : TEXCOORD3;

		#ifdef GRASS_TEXTURE_ATLAS
			uint textureAtlasIndex : COLOR1;
		#endif
	#endif
};

struct GrassSurfaceOutput
{
	half Subsurface;
};


// ========================== HELPER FUNCTIONS ==============================
//Random value from 2D value between 0 and 1
inline float rand(float2 co){
	return frac(sin(dot(co.xy, float2(12.9898,78.233))) * 43758.5453);
}

#if defined(GRASS_CALC_GLOBAL_WIND)
#include "GrassWind.hlsl"
#endif

//Get the grass normal from the up direction (or bended up direction) of the grass
inline half3 getNormal(half3 up, half3 right, half3 lightDir)
{
	#if defined(GRASS_RANDOM_DIR)
		return normalize(cross(right, up));
	#else
		//Calculate everything as if the grass was perpendicular to the direction of the light, 
		//so rotating the camera does not affect the lighting
		half3 grassSegmentRight = cross(up, lightDir);
		return normalize(cross(grassSegmentRight, up));
	#endif
}

inline half nextPow2(half input)
{
	return pow(2, (ceil(log2(input))));
}

//Seriously expensive operation. You shouldn't use this too much. Unfortunately it's needed for the camera/renderer position.
//From http://answers.unity3d.com/questions/218333/shader-inversefloat4x4-function.html
inline float4x4 inverse(float4x4 input)
{
#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
	//determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))

	float4x4 cofactors = float4x4(
		minor(_22_23_24, _32_33_34, _42_43_44),
		-minor(_21_23_24, _31_33_34, _41_43_44),
		minor(_21_22_24, _31_32_34, _41_42_44),
		-minor(_21_22_23, _31_32_33, _41_42_43),

		-minor(_12_13_14, _32_33_34, _42_43_44),
		minor(_11_13_14, _31_33_34, _41_43_44),
		-minor(_11_12_14, _31_32_34, _41_42_44),
		minor(_11_12_13, _31_32_33, _41_42_43),

		minor(_12_13_14, _22_23_24, _42_43_44),
		-minor(_11_13_14, _21_23_24, _41_43_44),
		minor(_11_12_14, _21_22_24, _41_42_44),
		-minor(_11_12_13, _21_22_23, _41_42_43),

		-minor(_12_13_14, _22_23_24, _32_33_34),
		minor(_11_13_14, _21_23_24, _31_33_34),
		-minor(_11_12_14, _21_22_24, _31_32_34),
		minor(_11_12_13, _21_22_23, _31_32_33)
		);
#undef minor
	return transpose(cofactors) / determinant(input);
}

inline float3 getCameraPos()
{
	#if defined(GRASS_PASS_SHADOWCASTER) && !defined(GRASS_RANDOM_DIR)
		return mul(inverse(UNITY_MATRIX_V), float4(0, 0, 0, 1)).xyz;
	#elif defined(GRASS_HDRP)
	    return float3(0,0,0);
	#else
		return _WorldSpaceCameraPos.xyz;
	#endif
}
#endif