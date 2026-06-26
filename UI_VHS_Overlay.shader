Shader "UI/VHS Overlay"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)

        _EffectStrength ("Effect Strength", Range(0, 1)) = 1
        _ScanlineIntensity ("Scanlines", Range(0, 1)) = 0.35
        _ScanlineScale ("Scanline Scale", Float) = 1
        _NoiseIntensity ("Noise", Range(0, 1)) = 0.12
        _ChromaticAberration ("Chromatic Aberration", Range(0, 0.02)) = 0.006
        _Vignette ("Vignette", Range(0, 1)) = 0.45
        _TapeWobble ("Tape Wobble", Range(0, 0.02)) = 0.004
        _RollingBand ("Rolling Band", Range(0, 0.25)) = 0.08

        [Header(Analog CRT)]
        _AnalogBarrel ("Analog Barrel (optional)", Range(0, 1)) = 0

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

            half _EffectStrength;
            half _ScanlineIntensity;
            half _ScanlineScale;
            half _NoiseIntensity;
            half _ChromaticAberration;
            half _Vignette;
            half _TapeWobble;
            half _RollingBand;
            half _AnalogBarrel;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.color = v.color * _Color;
                return OUT;
            }

            float hash12(float2 p)
            {
                float3 p3 = frac(float3(p.xyx) * 0.1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.x + p3.y) * p3.z);
            }

            float2 AnalogBarrelConvex(float2 uv, float strength)
            {
                float2 c = uv - 0.5;
                float aspect = _ScreenParams.x / max(_ScreenParams.y, 1.0);
                c.x *= aspect;
                float r2 = dot(c, c);
                float k = strength * 0.42;
                k = min(k, 0.28);
                c *= 1.0 + k * r2;
                c.x /= aspect;
                return c + 0.5;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
                float t = _Time.y;

                uv = AnalogBarrelConvex(uv, _AnalogBarrel);

                float wobble = sin(uv.y * 80.0 + t * 6.28) * _TapeWobble * _EffectStrength;
                uv.x += wobble;

                float2 ca = float2(_ChromaticAberration, 0) * _EffectStrength;
                fixed4 col;
                col.r = tex2D(_MainTex, uv + ca).r;
                col.g = tex2D(_MainTex, uv).g;
                col.b = tex2D(_MainTex, uv - ca).b;
                col.a = tex2D(_MainTex, uv).a;

                col += _TextureSampleAdd;

                float scan = sin(uv.y * 900.0 * _ScanlineScale * 3.14159) * 0.5 + 0.5;
                float scanDark = lerp(1.0, 1.0 - _ScanlineIntensity, _EffectStrength);
                col.rgb *= lerp(scanDark, 1.0, scan);

                float n = hash12(uv * 800.0 + t * 60.0);
                col.rgb += (n - 0.5) * 2.0 * _NoiseIntensity * _EffectStrength;

                float roll = sin(uv.y * 40.0 - t * 2.5);
                float band = smoothstep(0.92, 1.0, abs(roll)) * _RollingBand * _EffectStrength;
                col.rgb *= 1.0 - band;

                float2 vc = uv - 0.5;
                float vig = 1.0 - dot(vc, vc) * _Vignette * _EffectStrength;
                col.rgb *= saturate(vig);

                col *= IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                col.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip(col.a - 0.001);
                #endif

                return col;
            }
            ENDCG
        }
    }
}
