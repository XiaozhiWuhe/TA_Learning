Shader "Common/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white"{ }
        _LastFrameTex ("Last Frame Texture", 2D) = "white"{ }
        _BlurAmount ("Blur Amount", Range(0, 0.9)) = 0.5
    }
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

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
            sampler2D _LastFrameTex;
            float _BlurAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 currentFrame = tex2D(_MainTex, i.uv);
                fixed4 lastFrame = tex2D(_LastFrameTex, i.uv);
                fixed4 col = lerp(currentFrame, lastFrame, _BlurAmount);
                return col;
            }
            ENDCG
        }
    }
}
