#ifndef GRASS_FRAG_URP
#define GRASS_FRAG_URP

// ========================== Universal render pipeline ========================
void InitializeInputData(FS_INPUT input, half3 normal, half3 viewDirWS, out InputData inputData)
{
    inputData = (InputData)0;

    #ifdef _ADDITIONAL_LIGHTS
    inputData.positionWS = input.worldPos;
    #endif

    #if !defined(GRASS_PASS_SHADOWCASTER)
    // No normal map
    inputData.normalWS = normal;

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    viewDirWS = SafeNormalize(viewDirWS);

    inputData.viewDirectionWS = viewDirWS;

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
	inputData.shadowCoord = TransformWorldToShadowCoord(input.worldPos);
    #else
    inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif
    inputData.fogCoord = input.fogCoord.x;
    inputData.bakedGI = max(half3(0, 0, 0), SampleSH(inputData.normalWS));
    #endif
}

#if defined(GRASS_PASS_UNIVERSALFORWARD)
half4 frag(FS_INPUT i) : SV_Target
{
	float3 worldPos = i.worldPos;

	SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
	GrassSurfaceOutput go = (GrassSurfaceOutput)0;

#if defined(GRASS_HYBRID_NORMAL_LIGHTING)
		half3 specularNormal = NormalizeNormalPerPixel(i.specularNormal);
		half3 normal = i.normal;
#else
		half3 normal = i.normal;
#endif

	o.Albedo = 0.0;
	o.Normal = normal;
	o.Emission = 0.0;
	o.Specular = 0;
	o.Smoothness = 1.0;
	o.Occlusion = 1.0;
	o.Alpha = 0.0;
	go.Subsurface = 0.0;

	surf(i, o, go);
	
	half4 c = 0;

#if defined(GRASS_UNLIT_LIGHTING)
		c = half4(o.Albedo, 1);
#else //Not unlit
		half3 viewDirWS = GetCameraPositionWS() - worldPos;
		
		InputData inputData;
        InitializeInputData(i, normal, viewDirWS, inputData);
		
#if defined(GRASS_HYBRID_NORMAL_LIGHTING)
		    c = GrassLighting(inputData, specularNormal, o.Albedo, o.Specular.rgb, o.Smoothness, o.Occlusion, go.Subsurface, o.Emission, o.Alpha);
#else
		    c = GrassLighting(inputData, inputData.normalWS, o.Albedo, o.Specular.rgb, o.Smoothness, o.Occlusion, go.Subsurface, o.Emission, o.Alpha);
#endif

        c.rgb = MixFog(c.rgb, inputData.fogCoord);
#endif //End not unlit block

	c.a = o.Alpha;
	return c;
}
#endif // GRASS_PASS_UNIVERSALFORWARD

#if defined(GRASS_PASS_SHADOWCASTER) || defined(GRASS_PASS_DEPTHONLY)
half4 frag(FS_INPUT i) : SV_Target
{
    float3 worldPos = i.worldPos;

    SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
    GrassSurfaceOutput go = (GrassSurfaceOutput)0;

    o.Albedo = 0.0;
    o.Normal = float3(0, 0, 0);
    o.Emission = 0.0;
    o.Specular = 0;
    o.Smoothness = 1.0;
    o.Occlusion = 1.0;
    o.Alpha = 0.0;
    go.Subsurface = 0.0;

    // call surface function
    surf(i, o, go);

    return 0;
}
#endif // GRASS_PASS_SHADOWCASTER

#endif