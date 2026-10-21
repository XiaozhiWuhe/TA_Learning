Shader "Custom/SceneDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white"{ }
        _BlurTex ("Blur Texture", 2D) = "white"{ }
        _FocusDistance ("Focus Distance", Float) = 10.0
        _FocusRange ("Focus Range", Float) = 5.0
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

            CGINCLUDE
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
            float4 _MainTex_TexelSize;
            sampler2D _BlurTex;
            sampler2D _CameraDepthTexture;

            float _FocusDistance;
            float _FocusRange;
            float _BlurSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 GaussianBlur(v2f i, float2 dir)
            {
                float2 uv = i.uv;
                float2 offset = _MainTex_TexelSize.xy * dir * _BlurSize;
                fixed4 col = tex2D(_MainTex, uv) * 0.4026;
                col += tex2D(_MainTex, uv + offset * 1) * 0.2442;
                col += tex2D(_MainTex, uv - offset * 1) * 0.2442;
                col += tex2D(_MainTex, uv + offset * 2) * 0.0545;
                col += tex2D(_MainTex, uv - offset * 2) * 0.0545;
                return col;
            }
            ENDCG

        // pass 0: horizontal blur pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragHorizontal

            fixed4 fragHorizontal(v2f i) : SV_Target
            {
                return GaussianBlur(i, float2(1.0, 0.0));
            }
            ENDCG
        }

        // pass 1: vertical blur pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragVertical

            fixed4 fragVertical(v2f i) : SV_Target
            {
                return GaussianBlur(i, float2(0.0, 1.0));
            }
            ENDCG
        }

        // pass 2: final pass to combine the blurred and original textures based on depth
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragFinal

            fixed4 fragFinal(v2f i) : SV_Target
            {
                fixed4 oriCol = tex2D(_MainTex, i.uv);
                fixed4 blurCol = tex2D(_BlurTex, i.uv);
                // get depth value from the camera depth texture
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                // convert depth to linear depth
                float linearDepth = LinearEyeDepth(depth);
                // calculate factor based on linear depth
                float distance = abs(linearDepth - _FocusDistance);
                float factor = saturate(distance / _FocusRange);

                return lerp(oriCol, blurCol, factor);
            }
            ENDCG
        }
    }
}
