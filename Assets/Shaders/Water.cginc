#ifndef _WATER_CG
#define _WATER_CG
#pragma enabled_cbuffer
#include "UnityCG.cginc"

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
float M_PI = 3.1415f;
//shadow map
sampler2D gLightShadow;

float2 Random(float2 p){
    return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453 * _Time.x);
}

float2 Rotate2(float rad, float2 x){
    float c = cos(rad);
    float s = sin(rad);
    return float2(x.x * c - x.y * s, x.x * s + x.y * c);
}

float3 Rotate3(float rad, float3 n){
    return float3(0.0, 0.0, 0.0);
}

#endif