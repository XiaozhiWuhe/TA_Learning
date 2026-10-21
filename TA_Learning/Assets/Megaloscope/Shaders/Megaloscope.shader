Shader "Common/Megaloscope"
{
    Properties
    {
        _Megnification("Magnification", Range(1, 5)) = 1.0
        _Radius("Radius", Range(0, 1)) = 0.5
        _Feather("Feather", Range(0.001, 0.2)) = 0.1
        _LensDistortion("Lens Distortion", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }
        LOD 100

        GrabPass
        {
            "_GrabTexture"
        }

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
                float4 grabPos : TEXCOORD1;
            };

            sampler2D _GrabTexture;
            float _Megnification;
            float _Radius;
            float _Feather;
            float _LensDistortion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //get the uv of the object
                //assume the center of the object is at (0.5, 0.5)
                float2 center = float2(0.5, 0.5);
                float2 offset = i.uv - center;

                //calculate the distance from the center
                float distance = length(offset);
                float2 newUV = i.grabPos.xy / i.grabPos.w;
                //calculate the weight based on distance and feather
                float factor = 1.0 - smoothstep(_Radius - _Feather, _Radius, distance);
                //center->flat
                //edge->bend
                float NormalizedDistance = saturate(distance / _Radius);
                float lensCurve = 1.0 - pow(NormalizedDistance, 2.0) * _LensDistortion;
                lensCurve = saturate(lensCurve);

                float currentMagnification = lerp(1.0, _Megnification * lensCurve, factor);
                float2 newOffset = offset / currentMagnification;
                newUV += (newOffset - offset);
                // if (distance < _Radius)
                // {
                //     //calculate
                //     float2 newOffset = offset / _Megnification;
                //     newUV += (newOffset - offset);
                // }
                fixed4 col = tex2D(_GrabTexture, newUV);
                return col;
            }
            ENDCG
        }
    }
}
