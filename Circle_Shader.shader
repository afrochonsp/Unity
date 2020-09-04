﻿Shader "Сircle_Shader"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
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
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
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
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

            float4 _Colors[100];
            float _Indexes[100];
            float _IndexesSum = 0;
            int _ColorsCount = 0;
            float4 _FrameColor;
            float _FrameSize;
            float4 _BorderColor;
            float _BorderSize;
            float4 _SecondBorderColor;
            float _SecondBorderSize;
            float4 _CenterColor;
            float _CenterSize;
            int _RealCount;
            float4 _MainTex_TexelSize;

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

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                half4 c = 1;
                bool draw = true;
                int2 center = _MainTex_TexelSize.zw / 2;
                int2 pixel = IN.texcoord * _MainTex_TexelSize.zw;
                int radius = center.x;
                float degree = 0, angleSum = 0;
                float _Distance = distance(pixel, center);
                if(_Distance / radius < _CenterSize)
                {
                    draw = false;
                    if(_Distance <= radius * _CenterSize / 2 - (radius * _CenterSize * _SecondBorderSize / 2))
                    c = _CenterColor;
                    else if(_Distance >= radius * _CenterSize / 2 + (radius * _CenterSize * _SecondBorderSize / 2))
                    c = _CenterColor;
                    else
                    return _SecondBorderColor;
                }
                if(1.0 - _Distance / radius <= _FrameSize && _FrameSize != 0)
                {
                    draw = false;
                    if(_Distance / radius >= 1.0 - (1-_SecondBorderSize) * _FrameSize / 2)
                    c = _FrameColor;
                    else if(_Distance / center.x <= 1.0 - (1+_SecondBorderSize) * _FrameSize / 2)
                    c = _FrameColor;
                    else
                    return _SecondBorderColor;
                }
                if(pixel.x > center.y)
                degree = degrees(acos((pixel.y - center.x) / (0.0001 + _Distance)));
                else
                degree = 360 - degrees(acos((pixel.y - center.x) / (0.0001 + _Distance)));
                float bias = _BorderSize * 256.0 / 1.414 / _RealCount * radius / _Distance;
                for (int i = 0; i < _ColorsCount; i++)
                {
                    angleSum += _Indexes[i] / _IndexesSum * 360;
                    if(degree < angleSum + bias && degree > angleSum - bias || degree < bias)
                    {
                        if(draw == true)
                        c = _BorderColor;
                        if(degree < angleSum + bias * _SecondBorderSize && degree > angleSum - bias * _SecondBorderSize || degree < bias * _SecondBorderSize)
                        if(_Distance / radius <= 1.0 - _FrameSize / 2 && _Distance / radius >= _CenterSize / 2)
                        c = _SecondBorderColor;
                        break;
                    }
                    if(degree < angleSum && draw == true)
                    {
                        c = _Colors[i];
                        break;
                    }
                }
                if(color.a == 0) c.a = color.a;
                return c;
            }
        ENDCG
        }
    }
}