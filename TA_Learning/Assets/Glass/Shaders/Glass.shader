Shader "Common/Glass"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 0.5)
        _BumpMap ("Normal Map", 2D) = "bump"{ }
        _DistortionStrength("Distortion Strength", Range(0, 50)) = 0.1
        _FresnelPower("Fresnel Power", Range(0.5, 2.5)) = 2
        _SpecularStrength("Specular Strength", Range(32, 64)) = 32
        _MistTexture("Mist Texture", 2D) = "white"{ }
        _BlurSize("Blur Size", Range(0, 5)) = 1
        _MistAmount("Mist Amount", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 100
        GrabPass
        {
            "_GrabPass"
        }
        Pass
        {
            name "FORWARD"
            tags
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 GrabPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float3 worldTangent : TEXCOORD4;
                float3 worldBitangent : TEXCOORD5;
            };

            fixed4 _BaseColor;
            sampler2D _BumpMap;
            sampler2D _GrabPass;
            float4 _BumpMap_ST;
            float _DistortionStrength;
            float _FresnelPower;
            float _SpecularStrength;
            sampler2D _MistTexture;
            float _BlurSize;
            float _MistAmount;
            float4 _GrabPass_TexelSize;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.GrabPos = ComputeGrabScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BumpMap);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                return o;
            }

            fixed4 GaussianBlurGrab(float4 baseGrabPos, float2 offsetOffset)
            {
                float2 texel = _GrabPass_TexelSize.xy * _BlurSize;
                float4 col = 0;

                //偏移坐标
                float2 offsets[9] =
                {
                    float2(-1, -1), float2(0, -1), float2(1, -1),
                    float2(-1, 0), float2(0, 0), float2(1, 0),
                    float2(-1, 1), float2(0, 1), float2(1, 1)
                };
                //3×3高斯权重，详见实践报告。
                float weights[9] =
                {
                    0.0625, 0.125, 0.0625,
                    0.125, 0.25, 0.125,
                    0.0625, 0.125, 0.0625
                };

                //对9个像素邻域进行加权求和
                for (int i = 0;
                i < 9;
                i++)
                {
                    float4 currentPos = baseGrabPos;
                    currentPos.xy += (offsets[i] * texel + offsetOffset) * currentPos.w;
                    col += tex2Dproj(_GrabPass, currentPos) * weights[i];
                }
                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));   //解码法线贴图
                fixed3 mistNoise = tex2D(_MistTexture, i.uv).rgb; //采样雾纹理

                float3x3 tbn = float3x3(i.worldTangent, i.worldBitangent, i.worldNormal); //构建TBN矩阵
                float3 worldNormal = normalize(mul(tangentNormal, tbn));    //将切线空间法线转换为世界空间法线

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);  //计算视线方向
                float NdotV = saturate(dot(worldNormal, viewDir));  //计算法线与视线方向的点乘
                float fresnel = pow(1.0 - NdotV, _FresnelPower);

                float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);  //计算光照方向
                float3 halfDir = normalize(LightDir + viewDir);   //计算半程向量
                float NdotH = saturate(dot(worldNormal, halfDir));  //计算法线与半程向量的点乘
                float specular = pow(NdotH, _SpecularStrength);   //计算高光分量
                fixed3 specColor = specular * _LightColor0.rgb;   //计算高光颜色

                float2 offset = tangentNormal.xy * (1.0 + mistNoise.r * _MistAmount) * _DistortionStrength * _GrabPass_TexelSize.xy;    //结合法线扰动和雾纹理计算偏移量
                fixed4 grabColor = GaussianBlurGrab(i.GrabPos, offset);   //高斯模糊采样

                fixed3 mistColor = fixed3(0.9, 0.9, 0.9); //雾颜色
                fixed3 mistMask = mistNoise * _MistAmount;  //根据雾量计算雾遮罩
                fixed3 baseColor = lerp(grabColor.rgb * _BaseColor.rgb, mistColor, mistMask); //根据雾量混合背景颜色和雾颜色
                fixed3 finalCol = lerp(baseColor, mistColor, fresnel * 0.3) + specColor;    //根据菲涅尔系数进行颜色混合
                return fixed4(finalCol, 1.0);
            }
            ENDCG
        }
    }
}
