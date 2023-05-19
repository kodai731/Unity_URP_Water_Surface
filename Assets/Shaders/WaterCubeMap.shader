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
        // GrabPass {
            // Tags { "QUEUE"="Transparent" 
            // "IGNOREPROJECTOR"="true" 
            // "RenderType"="Transparent" 
            // "SurfaceType"="Transparent"
            // }

            // "_GrabPassWaterSurface"
        // }

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
            //Blend SrcAlpha OneMinusSrcAlpha
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
            sampler2D _HeightMap;
            sampler2D _CameraDepthTexture;
            sampler2D _CameraOpaqueTexture;

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
                float2 distortion = sin(i.uv.y * 50 + _Time.w) * 0.1f;
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
            //Blend SrcAlpha OneMinusSrcAlpha
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
                //float4 grabPos : TEXCOORD5;
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
                return float4(col.xyz, 0.8);
            }
            ENDHLSL
        }
    }
}
