Shader "WaterCubeMap"
{
    Properties
    {
        _Cube ("Cube", CUBE) = "" {}
        [Normal] _HeightMap ("Texture", 2D) = ""{}
        _HeightScale("HeightScale", Range(0.0, 20.0)) = 10.0
        _Speed("Speed", Float) = 1
        _Split("Split", Range(0.1, 20.0)) = 1
        _OffsetUV("OffsetUV", Float) = 0.01
        _Degree("Degree", Range(0.0, 360.0)) = 0
        _DepthFactor("DepthFactor", Range(0.0, 10.0)) = 0
    }
    SubShader
    {
        Tags { "QUEUE"="Transparent" 
        "IGNOREPROJECTOR"="true" 
        "RenderType"="Transparent"
        "SurfaceType" = "Transparent" 
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        //can not useded in URP
        //https://redhologerbera.hatenablog.com/entry/2022/04/01/222158

        //distortion
        
        Pass{
            Name "WaterSurface1"
            Tags { "QUEUE"="Transparent" 
            "IGNOREPROJECTOR"="true" 
            "RenderType"="Transparent" 
            "SurfaceType"="Transparent"
            //"LightMode" = "UniversalForward"
            }
            //ZTEST Less
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Water.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 scrPos : TEXCOORD2;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            UNITY_DECLARE_TEXCUBE(_Cube);
            sampler2D _CameraOpaqueTexture;
            float _Degree;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.scrPos = ComputeScreenPos(o.vertex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target{
                float preY = cos(i.uv.y * 50 + _Time.w * _Speed * 0.5);
                float preX = cos(i.uv.x * 50 + _Time.w * _Speed * 0.5);
                float pre = cos((float(i.uv.y) / float(i.uv.x)) + _Time.w * _Speed * 0.5);
                float amp = tan(float(i.uv.y) / (float(i.uv.x)) + 1);
                float2 distortion = float2(0, preY) * 0.025f;
                distortion = Rotate2((_Degree / 180.0) * 3.1415, distortion);
                float2 rotatePos = Rotate2((_Degree / 180.0) * 3.1415, i.grabPos.xy);
                float2 distortionUV = (i.grabPos.xy + distortion) / i.grabPos.w;
                fixed4 color = tex2D(_CameraOpaqueTexture, distortionUV);
                color.w = 0.8;
                return color;
            }
            ENDHLSL

        }
        
        //water surface
        Pass
        {
            Name "WaterSurface2"
            Tags { "QUEUE"="Transparent" 
            "IGNOREPROJECTOR"="true" 
            "RenderType"="Transparent" 
            "SurfaceType"="Transparent"
            "LightMode" = "UniversalForward"
            }
            //ZTEST Less
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Water.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 binormal : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            UNITY_DECLARE_TEXCUBE(_Cube);
            sampler2D _HeightMap;
            sampler2D _CameraDepthTexture;
            sampler2D _GrabPassWaterSurface;
            sampler2D _CameraOpaqueTexture;
            float _HeightScale;
            float _Speed;
            float _Split;
            float _OffsetUV;
            float _DepthFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent)).xyz;
                o.binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.binormal = normalize(mul(unity_ObjectToWorld, o.binormal));
                o.screenPos = ComputeScreenPos(o.vertex) + cos(_Time.w * _Speed) * 0.1;
                //o.grabPos = v.vertex;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 random = Random(i.uv);
                random = float2(smoothstep(0, 0.05, random.x), smoothstep(0, 0.05, random.y));
                float2 texUV = float2(clamp(0, 1, i.uv.x + _OffsetUV), clamp(0, 1, i.uv.y + _OffsetUV));
                float3 localNormal = UnpackNormalWithScale(tex2D(_HeightMap, (texUV * _Split + _Time.x * _Speed / 2)), _HeightScale);
                // float3 localNormal = UnpackNormal(tex2D(_HeightMap, (i.uv * _HeightScale) + _Time.x * _Speed / 2));
                i.normal = i.tangent * localNormal.x + i.binormal * localNormal.y + i.normal * localNormal.z;
                //i.normal = normalize(i.normal);
                //i.normal = normalize(localNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 refDir = reflect(-viewDir, i.normal);
                float4 col = UNITY_SAMPLE_TEXCUBE(_Cube, refDir);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                /*
                bound effect
                but not water surface colored
                */
                // float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                // half depth = LinearEyeDepth(depthSample);
                // half screenDepth = depth - i.screenPos.w;
                // float foamLine = 1 - saturate(screenDepth * _DepthFactor);
                // fixed4 col2 = lerp(col, fixed4(1, 0, 0, 1), foamLine);
                return float4(col.xyz, 0.7);
            }
            ENDHLSL
        }
    }
}
