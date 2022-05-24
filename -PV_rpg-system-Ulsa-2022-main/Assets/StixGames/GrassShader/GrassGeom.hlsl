#ifndef GRASS_GEOM
#define GRASS_GEOM

inline FS_INPUT geomToFrag(GS_OUTPUT v)
{
	FS_INPUT o = (FS_INPUT) 0;
	UNITY_INITIALIZE_OUTPUT(FS_INPUT, o)

	float3 worldPos = v.vertex.xyz;

	//This is necessary for shadow calculation
	v.vertex = mul(unity_WorldToObject, v.vertex);

	#ifdef GRASS_CURVED_WORLD
		V_CW_TransformPoint(v.vertex);
	#endif

	o.worldPos = worldPos;

	#if !defined(SIMPLE_GRASS)
		o.uv = v.uv;
		o.texIndex = v.texIndex;

		#ifdef GRASS_TEXTURE_ATLAS
			o.textureAtlasIndex = v.textureAtlasIndex;
		#endif
	#endif

	o.color = v.color;
	o.floorColor = v.floorColor;

	#ifndef GRASS_PASS_SHADOWCASTER
	    #if defined(GRASS_URP)
			VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
		    o.pos = vertexInput.positionCS;
        #else
            o.pos = UnityObjectToClipPos(v.vertex);
        #endif
		o.normal = v.normal;

        // HDRP uses deferred rendering, so the following values aren't necessary
        #if !defined(GRASS_HDRP)
            #if defined(GRASS_HYBRID_NORMAL_LIGHTING)
                o.specularNormal = v.specularNormal;
            #endif
    
            #if defined(GRASS_URP)
                o.shadowCoord = GetShadowCoord(vertexInput);
                o.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
            #else
                TRANSFER_SHADOW(o); // pass shadow coordinates to pixel shader
                UNITY_TRANSFER_FOG(o, o.pos); // pass fog coordinates to pixel shader
            #endif
        #endif
	#else // GRASS_PASS_SHADOWCASTER
	    #if defined(GRASS_URP)
	        VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
		    o.pos = vertexInput.positionCS;
	    #elif defined(GRASS_HDRP)
	        o.pos = UnityObjectToClipPos(v.vertex);
	    #else
	        TRANSFER_SHADOW_CASTER(o)
	    #endif
	#endif

	return o;
}

inline void generateBladeOfGrass(inout TriangleStream<FS_INPUT> triStream, GS_OUTPUT pIn, int lod,
	float3 rendererPos, float3 oPos, half3 up, half3 groundRight, half realHeight,
	half width, half4 color, half4 floorColor,
	half2 windDir, half3 interaction, half softness, half grassWeight)
{
	//Get lightDir
	#if defined(GRASS_HDRP)
	    // HDRP is deferred only
	    half3 lightDir = half3(0,0,0);
	#elif defined(GRASS_URP)
	    half3 lightDir = GetMainLight().direction;
	#else
        #if defined(USING_DIRECTIONAL_LIGHT)
            half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
        #else
            half3 lightDir = normalize(UnityWorldSpaceLightDir(oPos));
        #endif
    #endif

	float3 lastPos = oPos - up * 0.01f;
	half stepSize = 1.0f / lod;

    // Movement direction
    half3 interactionRight = half3(1, 0, 0);
    // This is probably not forward, but I have to keep it consistent with the interaction system
    half3 interactionForward = cross(interactionRight, up);
    half3 windInteraction = windDir.x * interactionRight + windDir.y * interactionForward;
    #if defined(GRASS_INTERACTION)
        half3 interactionVector = normalize(interaction.x * interactionRight + interaction.z * up + interaction.y * interactionForward);
        half interactionStrength = 1 - dot(interactionVector, up);
        half3 interactionDir = normalize(windInteraction * (1-interactionStrength) + interactionVector);
    #else
        half3 interactionDir = normalize(windInteraction + up);
        half interactionStrength = 0;
    #endif
    half adjustedSoftness = 1 - (1 - interactionStrength) * (1 - softness);
    half3 grassDir = normalize(interactionDir * adjustedSoftness + up * (1 - adjustedSoftness));
    
    half stepWeight = grassWeight * stepSize;

    float3 pos = oPos;
	for(half i = 0; i <= lod; i++)
	{
		half segment = i*stepSize;
		half sqrSegment = segment*segment;

		half uvHeight = segment;

        // TODO: Custom lighting effects for additional lights in URP / Probably not possible unless it's done per-pixel
		#if !defined(GRASS_HDRP) && !defined(GRASS_URP) && !defined(USING_DIRECTIONAL_LIGHT)
			lightDir = normalize(UnityWorldSpaceLightDir(pos));
		#endif

		half3 currentUp = pos - lastPos;

		half3 right = groundRight;

		//Vertex definition
		#if defined(SIMPLE_GRASS)
			//Simple grass has no texture, so the mesh has to look like a blade of grass
			pIn.vertex =  float4((pos - width * right * (1 - sqrSegment)).xyz, 1);
		#else
			pIn.vertex =  float4((pos - width * right).xyz, 1);
		#endif
		
		#if defined(GRASS_HYBRID_NORMAL_LIGHTING)
			// Use the hybrid normal mode
			pIn.specularNormal = getNormal(currentUp, right, lightDir);
		#elif !defined(GRASS_SURFACE_NORMAL_LIGHTING)
			// The regular lighting mode is used, there is no normal information in pIn yet
			pIn.normal = getNormal(currentUp, right, lightDir);
		#endif

		#if !defined(SIMPLE_GRASS)
			pIn.uv = half2(0.0f, uvHeight);
		#endif

		pIn.color = color;
		pIn.floorColor = half4(floorColor.rgb, 1-segment);
		triStream.Append(geomToFrag(pIn));

		//Vertex definition
		#if defined(SIMPLE_GRASS)
			//Simple grass has no texture, so the mesh has to look like a blade of grass
			pIn.vertex =  float4((pos + width * right * (1 - sqrSegment)).xyz, 1);
		#else
			pIn.vertex =  float4((pos + width * right).xyz, 1);
		#endif
		
		#if defined(GRASS_HYBRID_NORMAL_LIGHTING)
			// Use the hybrid normal mode
			pIn.specularNormal = getNormal(currentUp, right, lightDir);
		#elif !defined(GRASS_SURFACE_NORMAL_LIGHTING)
			// The regular lighting mode is used, there is no normal information in pIn yet
			pIn.normal = getNormal(currentUp, right, lightDir);
		#endif

		#if !defined(SIMPLE_GRASS)
			pIn.uv = half2(1.0f, uvHeight);
		#endif
		
		triStream.Append(geomToFrag(pIn));

		lastPos = pos;
		
		// =========== Grass position / direction code ===========
		// Next step in grass growth
		pos += grassDir * realHeight * stepSize;
		
		// Calculate change in grass direction
		grassDir = normalize(grassDir - stepWeight * up);
	}
				
	triStream.RestartStrip();
}

inline void pointGeometryShader(GS_INPUT p, float3 randCalcOffset, inout TriangleStream<FS_INPUT> triStream)
{
	float3 rendererPos = p.cameraPos;
	float3 cameraPos = _WorldSpaceCameraPos;

	//Init pos, uv
	float3 oPos = p.position.xyz;
	half4 uv = half4(p.uv, 0, 0);

	//This variable is used for calculating random values. If you have a better name for it, I'm all ears!
	#ifdef GRASS_OBJECT_MODE
		float3 randCalcPos = p.objectSpacePos;
	#else
		float3 randCalcPos = oPos;
	#endif

	randCalcPos += randCalcOffset;

	//Calculate viewDir and groundRight vector
	#ifdef GRASS_FOLLOW_SURFACE_NORMAL
		half3 up = normalize(p.normal);
	#else
		half3 up = half3(0, 1, 0);
	#endif
	
	half3 viewDir = normalize(rendererPos - oPos);
	half3 cameraForward = UNITY_MATRIX_V[2].xyz;

	//Set grass orientation
	#if defined(GRASS_RANDOM_DIR)
		half3 orientationDir = half3(rand(randCalcPos.xz + float2(-58.88, 77.51)), 0, rand(randCalcPos.xz + float2(54.85, -12.3))) * 2 - half3(1, 0, 1);
	#else
		half3 orientationDir = viewDir;
	#endif

	//Grass variable declaration
	half maxHeight = 0;
	half minHeight = 0;
	half width = 0;
	half softness = 0;
	half grassWeight = 0;
	#ifndef GRASS_PASS_SHADOWCASTER
		half4 mainColor = half4(0, 0, 0, 0);
		half4 secColor = half4(0, 0, 0, 0);
	#endif
	#ifdef GRASS_TEXTURE_ATLAS
		int textureAtlasIndex = 0;
	#endif

	#if !defined(UNIFORM_DENSITY)
		#ifdef VERTEX_DENSITY
			//Vertex density
			half4 density = p.color;
		#else
			//Texture density
			half4 density = tex2Dlod(_DensityTexture, uv);
		#endif
	#endif

	#if defined(SIMPLE_GRASS)
		float randVal = rand(randCalcPos.xz + float2(17.89, -23.60));

		if(randVal < DENSITY00)
		{
			maxHeight = _MaxHeight00;
			minHeight = _MinHeight00;
			width = _Width00;
			softness = _Softness00;
			grassWeight = _Weight00;
			#ifndef GRASS_PASS_SHADOWCASTER
				mainColor = _Color00;
				secColor = _SecColor00;
			#endif
		}
		else
		{
            GS_OUTPUT pIn = (GS_OUTPUT) 0;

			triStream.Append(geomToFrag(pIn));
			return;
		}
	#else //If textured grass
		//Grass Type
		//Selects a random type of grass. If the probability is over 1, it will be scaled down.
		#ifdef FOUR_GRASS_TYPES
			float randVal = rand(randCalcPos.xz + float2(17.89, -23.60)) * max(DENSITY00 + DENSITY01 + DENSITY02 + DENSITY03, 1);
		#elif defined(THREE_GRASS_TYPES)
			float randVal = rand(randCalcPos.xz + float2(17.89, -23.60)) * max(DENSITY00 + DENSITY01 + DENSITY02, 1);
		#elif defined(TWO_GRASS_TYPES)
			float randVal = rand(randCalcPos.xz + float2(17.89, -23.60)) * max(DENSITY00 + DENSITY01, 1);
		#else
			float randVal = rand(randCalcPos.xz + float2(17.89, -23.60));
		#endif
		int texIndex = 0;
		
		#ifdef GRASS_TEXTURE_ATLAS
			float textureAtlasRandVal = rand(randCalcPos.xz + float2(-23.46, 12.46));
		#endif

		if(randVal < DENSITY00)
		{
			texIndex = 0;
			maxHeight = _MaxHeight00;
			minHeight = _MinHeight00;
			width = _Width00;
			softness = _Softness00;
			grassWeight = _Weight00;
			#ifndef GRASS_PASS_SHADOWCASTER
				mainColor = _Color00;
				secColor = _SecColor00;
			#endif
			#ifdef GRASS_TEXTURE_ATLAS
				textureAtlasIndex = (int)(textureAtlasRandVal * _TextureAtlasWidth00 * _TextureAtlasHeight00);
			#endif
		}
		#if !defined(ONE_GRASS_TYPE)
		else if(randVal < (DENSITY00 + DENSITY01))
		{
			texIndex = 1;
			maxHeight = _MaxHeight01;
			minHeight = _MinHeight01;
			width = _Width01;
			softness = _Softness01;
			grassWeight = _Weight01;
			#ifndef GRASS_PASS_SHADOWCASTER
				mainColor = _Color01;
				secColor = _SecColor01;
			#endif
			#ifdef GRASS_TEXTURE_ATLAS
				textureAtlasIndex = (int)(textureAtlasRandVal * _TextureAtlasWidth01 * _TextureAtlasHeight01);
			#endif
		}
		#if !defined(TWO_GRASS_TYPES)
		else if(randVal < (DENSITY00 + DENSITY01 + DENSITY02))
		{
			texIndex = 2;
			maxHeight = _MaxHeight02;
			minHeight = _MinHeight02;
			width = _Width02;
			softness = _Softness02;
			grassWeight = _Weight02;
			#ifndef GRASS_PASS_SHADOWCASTER
				mainColor = _Color02;
				secColor = _SecColor02;
			#endif
			#ifdef GRASS_TEXTURE_ATLAS
				textureAtlasIndex = (int)(textureAtlasRandVal * _TextureAtlasWidth02 * _TextureAtlasHeight02);
			#endif
		}
		#if !defined(THREE_GRASS_TYPES)
		else if(randVal < (DENSITY00 + DENSITY01 + DENSITY02 + DENSITY03))
		{
			texIndex = 3;
			maxHeight = _MaxHeight03;
			minHeight = _MinHeight03;
			width = _Width03;
			softness = _Softness03;
			grassWeight = _Weight03;
			#ifndef GRASS_PASS_SHADOWCASTER
				mainColor = _Color03;
				secColor = _SecColor03;
			#endif
			#ifdef GRASS_TEXTURE_ATLAS
				textureAtlasIndex = (int)(textureAtlasRandVal * _TextureAtlasWidth03 * _TextureAtlasHeight03);
			#endif
		}
		#endif
		#endif
		#endif
		else
		{
			//If no grass type was randomized, return a single vertex, so no blade of grass will be rendered.
            GS_OUTPUT pIn = (GS_OUTPUT)0;

			pIn.texIndex = -1;

			triStream.Append(geomToFrag(pIn));
			return;
		}
	#endif

	//Calculate wind
	#if defined(GRASS_CALC_GLOBAL_WIND)
		half2 windDir = wind(randCalcPos, _WindRotation);
	#else
		half2 windDir = half2(0, 0);
	#endif

	//Add disorder offset
	half randX = (rand(randCalcPos.xz + 10) * 2 - 1) * _Disorder;
	half randZ = (rand(randCalcPos.xz - 10) * 2 - 1) * _Disorder;

	//If grass is looked at from the top, it should still look like grass
	#if defined(GRASS_TOP_VIEW_COMPENSATION)
		half topViewCompensation = 1 + pow(max(0, dot(viewDir, up)), 20) * 0.8;
		width *= topViewCompensation;
		
		windDir += half2(randX, randZ) * topViewCompensation;
	#else
		windDir += half2(randX, randZ);
	#endif

	//Grass height from color map
	half4 tex = tex2Dlod(_ColorMap, uv);

	//Grass height from distance falloff
	half dist = distance(oPos, cameraPos);

	half grassHeightMod = tex.a * smoothstep(_GrassFadeEnd, _GrassFadeStart, dist);
	
	//Tessellation smoothing by height
	#if defined(GRASS_HEIGHT_SMOOTHING)
		grassHeightMod *= p.smoothing;
	#endif

	//Tessellation smoothing by width
	#if defined(GRASS_WIDTH_SMOOTHING)
		width *= p.smoothing;
	#endif

	//Calculate real height
	half realHeight = (rand(randCalcPos.xz) * (maxHeight - minHeight) + minHeight) * grassHeightMod;

	//LOD
	int lod = (int) max(smoothstep(_LODEnd, _LODStart, dist)*_LODMax, 1);

	//Calculate grass interaction
	half3 interaction = half3(0, 0, 1);
	half4 burnFactor = half4(1, 1, 1, 1);
	#if defined(GRASS_INTERACTION)
		#if defined(GRASS_RENDERTEXTURE_INTERACTION)
		    #if defined(GRASS_HDRP)
		        float2 coords = (oPos.xz + _WorldSpaceCameraPos.xz - _GrassRenderTextureArea.xy) / _GrassRenderTextureArea.zw;
		    #else
		        float2 coords = (oPos.xz - _GrassRenderTextureArea.xy) / _GrassRenderTextureArea.zw;
		    #endif
			
			half4 interactionTexture = tex2Dlod(_GrassRenderTextureInteraction, float4(coords, 0, 0));
			interaction.xyz = normalize(interactionTexture.rgb * 2 - float3(1, 1, 1));
			burnFactor = tex2Dlod(_GrassRenderTextureBurn, float4(coords, 0, 0));
		#else
			interaction = tex2Dlod(_Displacement, uv).rgb;

			//Convert from texture to vector
			interaction.xy = (interaction.xy * 2.0) - half2(1, 1);
		#endif
	#endif

	//Width is split up by offset to right and to left, so we only need half
	width *= 0.5;

	realHeight *= burnFactor.a;
	//width *= burnFactor;

    //Abort generating grass, when certain values are too low
    //Both could probably be replaced by realHeight < 0.01, but I don't want to break compatibility with very small scenes
    if (dist > _GrassFadeEnd || burnFactor.a < _BurnCutoff)
	{
        GS_OUTPUT pIn = (GS_OUTPUT)0;

		triStream.Append(geomToFrag(pIn));
		return;
	}

	//Color
	half4 color = half4(1,1,1,1);
	#if !defined(GRASS_PASS_SHADOWCASTER)
		color = tex;
		color *= lerp(mainColor, secColor, rand(randCalcPos.xz + half2(10, -10)));
		color *= half4(burnFactor.rgb, 1);
	#endif

	#if defined(GRASS_ALPHA_SMOOTHING) && !defined(SIMPLE_GRASS)
		color.a = p.smoothing;
	#else
		color.a = 1.0f;
	#endif

	//Calculate the floor color
	half4 floorColor = _GrassFloorColor * tex2Dlod(_GrassFloorColorTexture, uv);
	floorColor.rgb *= burnFactor.rgb;

	//Cacluate ground right direction
	half3 groundRight = normalize(cross(up, orientationDir));

	//Set all default values, that (can) stay the same for the whole blade of grass
	GS_OUTPUT pIn;

	#if !defined(SIMPLE_GRASS)
		pIn.texIndex = texIndex;
	#endif
	
	#ifdef GRASS_TEXTURE_ATLAS
		pIn.textureAtlasIndex = textureAtlasIndex;
	#endif

	//Set the surface normal for rendering
	#if defined(GRASS_SURFACE_NORMAL_LIGHTING) || defined(GRASS_HYBRID_NORMAL_LIGHTING)
		pIn.normal = normalize(p.normal);
	#endif

	//Generate the grass itself
	generateBladeOfGrass(/* inout */ triStream, pIn, 
		lod, rendererPos, oPos, up, groundRight,
		realHeight, width, 
		color, floorColor, windDir, interaction, softness, grassWeight);

	#if defined(GRASS_RANDOM_DIR)
	generateBladeOfGrass(/* inout */ triStream, pIn,
		lod, rendererPos, oPos, up, -groundRight,
		realHeight, width,
		color, floorColor, windDir, interaction, softness, grassWeight);
	#endif
}

#if defined(GRASS_RANDOM_DIR)
[maxvertexcount(2 * MAX_VERTEX_COUNT)]
#else
[maxvertexcount(MAX_VERTEX_COUNT)]
#endif
void geom(triangle GS_INPUT p[3], inout TriangleStream<FS_INPUT> triStream)
{
	pointGeometryShader(p[0], float3(0, 0, 0), /* inout */ triStream);
	//pointGeometryShader(p[1], float3(0.01, 0, 0), /* inout */ triStream);
	//pointGeometryShader(p[2], float3(0, 0, 0.01), /* inout */ triStream);
}
#endif