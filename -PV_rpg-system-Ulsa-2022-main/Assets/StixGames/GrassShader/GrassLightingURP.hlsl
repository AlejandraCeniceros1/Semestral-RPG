#ifndef GRASS_LIGHTING_URP
#define GRASS_LIGHTING_URP

// Taken from the Unity URP
// Based on Minimalist CookTorrance BRDF
// Implementation is slightly different from original derivation: http://www.thetenthplanet.de/archives/255
//
// * NDF [Modified] GGX
// * Modified Kelemen and Szirmay-Kalos for Visibility term
// * Fresnel approximated with 1/LdotH
half3 GrassDirectBDRF(BRDFData brdfData, half3 normalWS, half3 specularNormal, half3 lightDirectionWS, half3 viewDirectionWS)
{
#ifndef _SPECULARHIGHLIGHTS_OFF
    float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));

    float NoH = saturate(dot(specularNormal, halfDir));
    half LoH = saturate(dot(lightDirectionWS, halfDir));

    // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
    // BRDFspec = (D * V * F) / 4.0
    // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
    // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
    // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
    // https://community.arm.com/events/1155

    // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
    // We further optimize a few light invariant terms
    // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
    float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;

    half LoH2 = LoH * LoH;
    half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);

    // On platforms where half actually means something, the denominator has a risk of overflow
    // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
    // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif

    half3 color = specularTerm * brdfData.specular + brdfData.diffuse;
    return color;
#else
    return brdfData.diffuse;
#endif
}

half3 GrassLightingPhysicallyBased(BRDFData brdfData, half3 lightColor, half3 lightDirectionWS, half lightAttenuation, half subsurface, half3 normalWS, half3 specularNormal,
	half3 viewDirectionWS)
{
    #if defined(GRASS_RANDOM_DIR)
        half3 subsurfaceGI = max(half3(0, 0, 0), SampleSH(-normalWS));
		half3 subsurfaceScattering = brdfData.diffuse * subsurface * (saturate(1 - saturate(dot(normalWS, lightDirectionWS))) * lightColor * lightAttenuation + subsurfaceGI);
	#endif

    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * (lightAttenuation * NdotL);
    
    #if !defined(GRASS_PBR_LIGHTING)
		//Mirror light dir and normal to get specular lighting on the same side as the sun/light. 
		//Just because it's not realistic, doesn't mean it doesn't look nice!
		lightDirectionWS = half3(-lightDirectionWS.x, lightDirectionWS.y, -lightDirectionWS.z);

		#if !defined(GRASS_RANDOM_DIR)
			//Randomly rotated grass has correct normals (because backfaces are rendered) so the normal doesn't have to be changed
			specularNormal = half3(-specularNormal.x, specularNormal.y, -specularNormal.z);
		#endif
	#endif
    
    half3 color = GrassDirectBDRF(brdfData, normalWS, specularNormal, lightDirectionWS, viewDirectionWS) * radiance;
    
    #if defined(GRASS_RANDOM_DIR)
		color += subsurfaceScattering;
	#endif
    
    return color;
}

half3 GrassLightingPhysicallyBased(BRDFData brdfData, Light light, half subsurface, half3 normalWS, half3 specularNormal, half3 viewDirectionWS)
{
    return GrassLightingPhysicallyBased(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, subsurface, normalWS, specularNormal, viewDirectionWS);
}

half3 GrassGlobalIllumination(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirectionWS)));

    half3 indirectDiffuse = bakedGI * occlusion;
    
    #if defined(GRASS_IGNORE_GI_SPECULAR)
        half3 indirectSpecular = half3(0,0,0);
    #else
        half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);
    #endif

    return EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
}

// ================ Grass Lighting ======================
#if defined(GRASS_UNSHADED_LIGHTING)
half4 GrassLighting(InputData inputData,
	half3 specularNormal,
    half3 albedo, half3 specular,
    half smoothness, half occlusion, half subsurface, half3 emission, half alpha)
{
    Light mainLight = GetMainLight(inputData.shadowCoord);
    half3 mainLightColor = mainLight.color * mainLight.distanceAttenuation * mainLight.shadowAttenuation;
    half3 color = albedo * (mainLightColor + inputData.bakedGI);
    
    #ifdef _ADDITIONAL_LIGHTS
        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
        {
            #if defined(ADDITIONAL_LIGHT_CALCULATE_SHADOWS)
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS, half4(1, 1, 1, 1));
            #else
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
            #endif
            color += albedo * light.color * light.distanceAttenuation * light.shadowAttenuation;
        }
    #endif
    
    return half4(color, alpha);
}
#else
half4 GrassLighting(InputData inputData,
	half3 specularNormal,
    half3 albedo, half3 specular,
    half smoothness, half occlusion, half subsurface, half3 emission, half alpha)
{
    BRDFData brdfData;
    InitializeBRDFData(albedo, 1.0f, specular, smoothness, alpha, brdfData);

    Light mainLight = GetMainLight(inputData.shadowCoord);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

	half3 color = GrassGlobalIllumination(brdfData, inputData.bakedGI, occlusion, specularNormal, inputData.viewDirectionWS);
    color += GrassLightingPhysicallyBased(brdfData, mainLight, subsurface, inputData.normalWS, specularNormal, inputData.viewDirectionWS);

    #ifdef _ADDITIONAL_LIGHTS
        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
        {
            #if defined(ADDITIONAL_LIGHT_CALCULATE_SHADOWS)
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS, half4(1, 1, 1, 1));
            #else
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
            #endif
            color += GrassLightingPhysicallyBased(brdfData, light, subsurface, inputData.normalWS, specularNormal, inputData.viewDirectionWS);
        }
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        color += inputData.vertexLighting * brdfData.diffuse;
    #endif

    color += emission;
    return half4(color, alpha);
}
#endif
#endif
