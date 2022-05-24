#ifndef GRASS_WIND
#define GRASS_WIND

#if !defined(GRASS_URP)
    #define _GrassTime _Time
#else
    float4 _GrassTime;
#endif

inline half windStrength(float3 pos)
{
	return pos.x + _GrassTime.w*_WindParams.y + 5 * cos(0.01f*pos.z + _GrassTime.y*_WindParams.y * 0.2f) + 4 * sin(0.05f*pos.z - _GrassTime.y*_WindParams.y*0.15f) + 
	    4 * sin(0.2f*pos.z + _GrassTime.y*_WindParams.y * 0.2f) + 2 * cos(0.6f*pos.z - _GrassTime.y*_WindParams.y*0.4f);
}

inline half windRippleStrength(float3 pos)
{
	return sin(100 * pos.x + _GrassTime.y*_WindParams.w * 3 + pos.z)*cos(10 * pos.x + _GrassTime.y*_WindParams.w * 2 + pos.z*0.5f);
}

inline half2 windRipple(float3 pos)
{
	return _WindParams.z * half2(windRippleStrength(pos), windRippleStrength(pos + float3(452, 0, 987)));
}

inline half2 wind(float3 pos)
{
	half2 windWaveStrength = _WindParams.x * sin(0.7f*windStrength(pos)) * cos(0.15f*windStrength(pos));
	windWaveStrength += windRipple(pos);

	return half2(windWaveStrength.x, windWaveStrength.y);
}

inline half2 wind(float3 pos, half rotation) 
{
	float3 realPos = float3(pos.x * cos(rotation) - pos.z * sin(rotation), pos.y, pos.x * sin(rotation) + pos.z * cos(rotation));

	half2 windValue = wind(realPos);

	return half2(windValue.x * cos(rotation) - windValue.y * sin(rotation), windValue.x * sin(rotation) + windValue.y * cos(rotation));
}

#endif