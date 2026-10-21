Shader "Common/Pixelization"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white"{ }
        _PixelSize("Pixel Size", Range(0, 256)) = 64
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
        }
        LOD 100

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
            float4 _MainTex_ST;
            float _PixelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float rotioX = floor(i.uv.x * _PixelSize) / _PixelSize;
                float rotioY = floor(i.uv.y * _PixelSize) / _PixelSize;

                // sample the texture
                fixed4 col = tex2D(_MainTex, float2(rotioX, rotioY));
                if (col.a < 0.5)
                {
                    discard;
                }
                return col;
            }
            ENDCG
        }
    }
}
