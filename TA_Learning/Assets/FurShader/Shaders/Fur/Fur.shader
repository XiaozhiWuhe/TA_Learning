Shader "Fur/Fur"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white"{ }
        _FurTex("Fur Texture", 2D) = "white"{ }
        _WindNoiseTex("Wind Noise Tex", 2D) = "white"{ }
        _Color("Color", Color) = (1, 1, 1, 1)
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularPower("Specular Power", Range(1, 128)) = 16

        _FurLength("Fur Length", Range(0, 0.02)) = 0.01
        _FurDensity("Fur Density", Range(0, 2)) = 1
        _FurShadow("Fur Shadow", Range(0, 0.25)) = 0.01

        _GravityForce("Gravity Force", Vector) = (0, 0, 0, 0)
        _WindDirection("Wind Direction", Vector) = (0, 0, 0, 0)
        _WindStrength ("Wind Strength", Range(0, 2)) = 1
        _WindSpeed ("Wind Speed", Range(0, 5)) = 1
        _WindNoiseScale ("Wind Noise Scale", Range(0.01, 2)) = 1

    }
    Category
    {
        SubShader
        {
            Tags
            {
                "RenderType" = "Transparent"
                "IgnoreProjector" = "True"
                "Queue" = "Transparent"
            }
            Cull Off
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert_surface
                #pragma fragment frag_surface
                #include "UnityCG.cginc"
                #define Furlayer 0
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.05
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.10
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.15
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.20
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.25
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.30
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.35
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.40
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.45
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.50
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.55
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.60
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.65
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.70
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.75
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.80
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.85
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.90
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 0.95
                #include "Fur.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert_basic
                #pragma fragment frag_basic
                #include "UnityCG.cginc"
                #define Furlayer 1.00
                #include "Fur.cginc"
                ENDCG
            }
        }
    }
}
