Shader "Common/Cartoon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white"{ }
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        // outline
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth("Outline Width", Range(0, 0.01)) = 0.01

        // cel
        _StepCount("StepCount", Range(3, 4)) = 4
        _Threshold1("Threshold 1", Range(0, 1)) = 0.25
        _Threshold2("Threshold 2", Range(0, 1)) = 0.50
        _Threshold3("Threshold 3", Range(0, 1)) = 0.75
        _Shade0("Shade 0", Range(0, 1)) = 0.30
        _Shade1("Shade 1", Range(0, 1)) = 0.45
        _Shade2("Shade 2", Range(0, 1)) = 0.75
        _Shade3("Shade 3", Range(0, 1)) = 1.00
        // we should make a transition between different levels.
        // otherwise the surface of material will being hard edges.
        _TransitionWidth("Transition Width", Range(0, 0.1)) = 0.02

        // sss
        _SSSColor("SSS Color", Color) = (1, 1, 1, 1)
        _SSSMask("SSS Mask", 2D) = "white"{ }
        _SSSIntensity("SSS Intensity", Range(0, 2)) = 1
        _SSSPower("SSS Power", Range(1, 8)) = 2.5
        _SSSWrap("SSS Wrap", Range(0, 1)) = 0.2

        // specular
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularMask ("Specular Shape Mask", 2D) = "white"{ }
        _SpecularIntensity("Specular Intensity", Range(0, 3)) = 1
        _SpecularPower ("Specular Power", Range(1, 128)) = 16
        _SpecularThreshold ("Specular Threshold", Range(0, 1)) = 0.5
        _SpecularSmoothness ("Specular Smoothness", Range(0.001, 0.2)) = 0.03
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 100
        Pass
        {
            NAME "OUTLINE"
            Cull Front
            ZWrite On
            ZTest Lequal
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineWidth;

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xyz += normalize(v.normal) * _OutlineWidth;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float2 uvSSS : TEXCOORD2;
                float2 uvSpec : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _StepCount;
            float _Threshold1;
            float _Threshold2;
            float _Threshold3;
            float _Shade0;
            float _Shade1;
            float _Shade2;
            float _Shade3;
            float _TransitionWidth;

            sampler2D _SSSMask;
            float4 _SSSMask_ST;
            float4 _SSSColor;
            float _SSSIntensity;
            float _SSSPower;
            float _SSSWrap;

            sampler2D _SpecularMask;
            float4 _SpecularMask_ST;
            float4 _SpecularColor;
            float _SpecularIntensity;
            float _SpecularPower;
            float _SpecularThreshold;
            float _SpecularSmoothness;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvSSS = TRANSFORM_TEX(v.uv, _SSSMask);
                o.uvSpec = TRANSFORM_TEX(v.uv, _SpecularMask);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // get the base color from MainTex
                fixed4 baseCol = tex2D(_MainTex, i.uv) * _Color;
                // Lambert:
                float3 normalDir = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfDir = normalize(lightDir + viewDir);
                float NdotL = saturate(dot(normalDir, lightDir));
                float NdotH = saturate(dot(normalDir, halfDir));
                // each color level
                float toonLight = _Shade0;
                float halfWidth = max(0, _TransitionWidth);

                float t1 = smoothstep(_Threshold1 - halfWidth, _Threshold1 + halfWidth, NdotL);
                toonLight += (_Shade1 - _Shade0) * t1;

                float t2 = smoothstep(_Threshold2 - halfWidth, _Threshold2 + halfWidth, NdotL);
                toonLight += (_Shade1 - _Shade0) * t2;
                if (_StepCount > 3.5)
                {
                    float t3 = smoothstep(_Threshold3 - halfWidth, _Threshold3 + halfWidth, NdotL);
                    toonLight += (_Shade1 - _Shade0) * t3;
                }
                // main & ambient light
                float3 direct = _LightColor0.rgb * toonLight;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                // sssmask
                float sssMask = tex2D(_SSSMask, i.uvSSS).r;
                // subsurface scattering approximation
                float backLight = dot(-normalDir, lightDir);
                float wrappedBackLight = saturate((backLight + _SSSWrap) / (1 + _SSSWrap));
                float sss = pow(wrappedBackLight, _SSSPower);
                /// sss contribution
                float3 sssCol = _SSSColor.rgb * sssMask * _SSSIntensity * sss * _LightColor0.rgb;
                // blinn-phong spec
                float specMask = tex2D(_SpecularMask, i.uvSpec).r;
                float spec = pow(NdotH, _SpecularPower);
                float specShape = smoothstep(_SpecularThreshold - _SpecularSmoothness, _SpecularThreshold + _SpecularSmoothness, spec);
                float3 specCol = _SpecularColor.rgb * specMask * _SpecularIntensity * specShape * _LightColor0.rgb;
                // final color
                float3 finalCol = baseCol.rgb * (direct + ambient) + baseCol * sssCol;
                finalCol += specCol;
                return fixed4(finalCol, baseCol.a);
            }
            ENDCG
        }
    }
}
