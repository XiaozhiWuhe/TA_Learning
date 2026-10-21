Shader "Common/Crack"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white"{ }
        _CrackMap1("CrackMap1", 2D) = "white"{ }
        _CrackMap2("CrackMap2", 2D) = "white"{ }
        _CrackMap3("CrackMap3", 2D) = "white"{ }

        _CrackThreshold("Crack Threshold", Range(0, 1)) = 1
        _CrackSoftness("Crack Softness", Range(0, 0.5)) = 0.5
        _Progress("Progress", Range(0, 1)) = 1
        _CrackColor("Crack Color", Color) = (0.9, 0.9, 1, 1)
        _CrackOpacity("Crack Opacity", Range(0, 1)) = 1

        _HighLightColor("High Light Color", Color) = (0.9, 0.9, 1, 1)
        _HighLightIntensity("High Light Intensity", Range(0, 5)) = 1
        _HighLightWidth("High Light Width", Range(0, 1)) = 1
        _HighLightStage("High Light Stage", Range(0, 3)) = 0
        _HighLightProgress("High Light Progress", Range(0, 1)) = 0
    }
    SubShader
    {
        Cull Off
        ZWrite Off
        Ztest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _CrackMap1;
            sampler2D _CrackMap2;
            sampler2D _CrackMap3;

            float4 _MainTex_TexelSize;
            float _CrackThreshold;
            float _CrackSoftness;
            float _Progress;
            float4 _CrackColor;
            float _CrackOpacity;

            float4 _HighLightColor;
            float _HighLightIntensity;
            float _HighLightWidth;
            float _IsHighLight;
            float4 _CrackMap1_TexelSize;
            int _HighLightStage;
            float _HighLightProgress;

            float ReadCrack(float value)
            {
                float minValue = max(0, _CrackThreshold - _CrackSoftness);
                float maxValue = min(_CrackThreshold + _CrackSoftness, 1);
                return smoothstep(minValue, maxValue, value);
            }
            void GetCrackMask(float2 uv, out float m1, out float m2, out float m3)
            {
                //cracks
                float c1 = ReadCrack(tex2D(_CrackMap1, uv).r);
                float c2 = ReadCrack(tex2D(_CrackMap2, uv).r);
                float c3 = ReadCrack(tex2D(_CrackMap3, uv).r);
                //progress each stage
                float p1 = saturate(_Progress * 3.0);
                float p2 = saturate(_Progress * 3.0 - 1.0);
                float p3 = saturate(_Progress * 3.0 - 2.0);
                //
                p1 = smoothstep(0, 1, p1);
                p2 = smoothstep(0, 1, p2);
                p3 = smoothstep(0, 1, p3);
                //mask each
                m1 = c1 * p1;
                m2 = c2 * p2;
                m3 = c3 * p3;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                fixed4 screenCol = tex2D(_MainTex, uv);
                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                    {
                        uv.y = 1 - uv.y;
                    }
                #endif
                //calculate the uv offset
                float m1, m2, m3;
                GetCrackMask(uv, m1, m2, m3);
                float crackMask = max(m1, max(m2, m3));
                //
                float2 offset = _CrackMap1_TexelSize.xy * _HighLightWidth;
                //each outline
                float2 uv1 = uv + float2(offset.x, 0);
                float2 uv2 = uv - float2(offset.x, 0);
                float2 uv3 = uv + float2(0, offset.y);
                float2 uv4 = uv - float2(0, offset.y);

                float a1, a2, a3;
                float b1, b2, b3;
                float c1, c2, c3;
                float d1, d2, d3;

                GetCrackMask(uv1, a1, a2, a3);
                GetCrackMask(uv2, b1, b2, b3);
                GetCrackMask(uv3, c1, c2, c3);
                GetCrackMask(uv4, d1, d2, d3);

                //the first one
                float outline1 = saturate(max(max(a1, b1), max(c1, d1)) - m1);

                //second
                float outline2 = saturate(max(max(a2, b2), max(c2, d2)) - m2);

                //3
                float outline3 = saturate(max(max(a3, b3), max(c3, d3)) - m3);

                //according stage->canHighLight?
                float stage1 = step(1.0, (float)_HighLightStage);
                float stage2 = step(2.0, (float)_HighLightStage);
                float stage3 = step(3.0, (float)_HighLightStage);

                if (_HighLightStage < 1.5)
                {
                    stage1 *= _HighLightProgress;
                }
                else if (_HighLightStage < 2.5)
                {
                    stage2 *= _HighLightProgress;
                }
                else
                {
                    stage3 *= _HighLightProgress;
                }

                float outline =
                outline1 * stage1 +
                outline2 * stage2 +
                outline3 * stage3;

                outline = saturate(outline);
                //calculate highlight
                float highLight = outline * _HighLightIntensity;
                //blend
                float finAlpha = saturate(screenCol.a * crackMask * _CrackOpacity);
                screenCol.rgb = lerp(screenCol.rgb, _CrackColor.rgb, finAlpha);
                screenCol.rgb += _HighLightColor.rgb * highLight * _HighLightColor.a;
                return screenCol;
            }
            ENDCG
        }
    }
}
