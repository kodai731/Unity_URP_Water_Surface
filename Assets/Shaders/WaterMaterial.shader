Shader "Unlit/WaterMaterial"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags{
            //"QUEUE" = "Opaque"
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
            "UniversalMaterialType" = "Lit" 
            "IgnoreProjector" = "True" 
            //"SurfaceType" = "Opaque"
            "ShaderModel"="2.0"
        }
        LOD 300
        Pass
        {
            Name "ForwardLit"
            Tags{
                //"QUEUE" = "Opaque"
                //"RenderPipeline" = "UniversalPipeline" 
                "LightMode" = "UniversalForward"
                //"SurfaceType" = "Opaque"
                //"RenderType"="Opaque"
                //"IgnoreProjector" = "True" 
            }
            Blend One Zero
            ZWrite[_ZWrite]
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            fixed4 _Color;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 color = tex2D(_MainTex, i.uv);
                //fixed4 color.xyz = _Color.xyz;
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(1.0, 1.0, 0.0, 0.5);
            }
            ENDHLSL
        }
    }
}
