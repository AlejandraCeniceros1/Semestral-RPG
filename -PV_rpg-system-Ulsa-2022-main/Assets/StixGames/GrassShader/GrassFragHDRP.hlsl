#ifndef GRASS_FRAG_HDRP
#define GRASS_FRAG_HDRP

#if defined(GRASS_PASS_GBUFFER)
void frag(  FS_INPUT i,
            out float4 base : SV_Target0,
            out float4 normalSmoothness : SV_Target1,
            out float4 noIdeaWhatThisIs : SV_Target2,
            out float4 emissive : SV_Target3
            )
{
	float3 worldPos = i.worldPos;

	SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	GrassSurfaceOutput go = (GrassSurfaceOutput)0;

	o.Albedo = 0.0;
	o.Normal = float3(0,0,0);
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 1.0;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;
	go.Subsurface = 0.0;

	// call surface function
	surf(i, o, go);

    base.rgb = o.Albedo;
    base.a = 1;
    normalSmoothness.xyz = o.Normal;
    normalSmoothness.a = 1;
    noIdeaWhatThisIs = float4(0,0,0,0);
    emissive = float4(o.Emission, 0);
}
#endif

#if defined(GRASS_PASS_SELECTION) || defined(GRASS_PASS_SHADOWCASTER) || defined(GRASS_PASS_DEPTHONLY)
void frag(FS_INPUT i
            #if defined(GRASS_PASS_DEPTHONLY)
            , out float4 outNormalBuffer : SV_Target0
            #elif defined(GRASS_PASS_SELECTION)
            , out float4 outColor : SV_Target0
            #endif
        )
{
	float3 worldPos = i.worldPos;

	SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	GrassSurfaceOutput go = (GrassSurfaceOutput)0;

	o.Albedo = 0.0;
	o.Normal = float3(0,0,0);
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 1.0;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;
	go.Subsurface = 0.0;

	// call surface function
	surf(i, o, go);

    #if defined(GRASS_PASS_DEPTHONLY)
    outNormalBuffer = float4(i.normal, 0);
    #endif

    #if defined(GRASS_PASS_SELECTION)
    outColor = float4(0, 1, 1.0, 1.0);
    #endif
}
#endif // GRASS_PASS_SHADOWCASTER

#endif // GRASS_FRAG_HDRP