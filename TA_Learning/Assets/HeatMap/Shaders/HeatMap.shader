Shader "HeatMap/HeatMap"
{
    Properties
    {
        _HeatTex("Heat Texture", 2D) = "white"{ }
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct vertInput
            {
                float4 pos : POSITION;
            };

            struct vertOutput
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            sampler2D _HeatTex;
            uniform int _Points_Count = 0;
            uniform float3 _PointPoses[100];
            uniform float2 _Properties[100];

            vertOutput vert(vertInput i)
            {
                vertOutput o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.worldPos = mul(unity_ObjectToWorld, i.pos).xyz;
                return o;
            }

            fixed4 frag(vertOutput o) : COLOR
            {
                float h = 0;

                for (int i = 0;
                i < _Points_Count;
                i++)
                {
                    // calculate the distance
                    // from the world coordinates of pixel
                    // to the heat point i.
                    float di = distance(o.worldPos, _PointPoses[i].xyz);

                    float ri = _Properties[i].x;

                    // calculate a partial linear effect.
                    float hi = 1 - saturate(di / ri);

                    h += hi * _Properties[i].y;
                }

                h = saturate(h);
                fixed4 col = tex2D(_HeatTex, float2(h, 0.5));
                return col;
            }
            ENDCG
        }
    }
}
