#ifndef _WATER_CG
#define _WATER_CG
#include "UnityCG.cginc"
#endif

struct DirectionalLight{
    float3 lightDir;
    half3 lightColor;
};

float4x4 gLightVP;
float3 gLightDir;
half3 gLightColor;
float gShadowBias;
float gShadowNormalBias;
float gShadowDistanceSquare;
//shadow map
sampler2D gLightShadow;

float2 Random(float2 p){
    return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453 * _Time.x);
}
