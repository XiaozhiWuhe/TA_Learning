#pragma target 3.0
#include "Lighting.cginc"
#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct v2f
{
    float4 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

sampler2D _MainTex;
sampler2D _FurTex;
sampler2D _WindNoiseTex;
float4 _MainTex_ST;
float4 _FurTex_ST;
half4 _Color;

half4 _SpecularColor;
float _SpecularPower;

float _FurLength;
float _FurDensity;
float _FurShadow;

float4 _GravityForce;
float4 _WindDirection;
float _WindStrength;
float _WindSpeed;
float _WindNoiseScale;

v2f vert_surface(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.uv, _FurTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    return o;
}

v2f vert_basic (appdata v)
{
    v2f o;
    float3 newPoint = v.vertex.xyz + v.normal * _FurLength * Furlayer;

    o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.uv, _FurTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    // force part begin
    // get uv from noise
    float2 noiseUV = o.worldPos.xz * _WindNoiseScale;
    //get dir
    float2 windDirXZ = normalize(_WindDirection.xz);
    noiseUV -= windDirXZ * _Time.y * _WindSpeed;
    float noise = tex2Dlod(_WindNoiseTex, float4(noiseUV, 0, 0)).r;

    // according to noise texture, get a factor
    float noiseFactor = lerp(0.3, 1.0, noise);
    // calculate windforce.
    float3 worldWind = normalize(_WindDirection.xyz) * _WindStrength * noiseFactor;
    float3 worldForce = worldWind + _GravityForce.xyz;
    float3 objectForce = mul(unity_WorldToObject, float4(worldForce, 0)).xyz;
    float3 force = clamp(objectForce, -1, 1);
    newPoint += force * pow(Furlayer, 3) * _FurLength;
    // force part end

    o.vertex = UnityObjectToClipPos(float4(newPoint, 1.0));
    return o;
}

fixed4 frag_surface(v2f i) : SV_Target
{
    // get the base color from MainTex
    fixed3 baseCol = tex2D(_MainTex, i.uv.xy).rgb * _Color;

    // Lambert:
    float3 normalDir = normalize(i.worldNormal);
    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 halfDir = normalize(lightDir + viewDir);
    float NdotL = saturate(dot(normalDir, lightDir));
    float NdotH = saturate(dot(normalDir, halfDir));

    // blinn-phong
    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    float3 diffuse = baseCol.xyz * _LightColor0.rgb * NdotL;
    float spec = pow(NdotH, _SpecularPower);
    float3 specCol = _SpecularColor.rgb * _LightColor0.rgb * spec;
    float3 finCol = baseCol + diffuse + specCol;
    return fixed4(finCol, 1);
}

fixed4 frag_basic (v2f i) : SV_Target
{
    // get MainTex
    fixed3 baseCol = tex2D(_MainTex, i.uv.xy).rgb * _Color;

    // the closer inside, the darker the hair
    baseCol -= pow((1 - Furlayer), 3) * _FurShadow;
    // another way/
    // float shadow = lerp(1, Furlayer, _FurShadow);
    // baseCol *= shadow;
    // /another way

    // Lambert:
    float3 normalDir = normalize(i.worldNormal);
    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 halfDir = normalize(lightDir + viewDir);
    float NdotL = saturate(dot(normalDir, lightDir));
    float NdotH = saturate(dot(normalDir, halfDir));

    // blinn-phong
    float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    float3 diffuse = baseCol.xyz * _LightColor0.rgb * NdotL;
    float spec = pow(NdotH, _SpecularPower);
    float3 specCol = _SpecularColor.rgb * _LightColor0.rgb * spec;
    float3 finCol = baseCol + diffuse + specCol;

    // get noiseTex
    float furNoise = tex2D(_FurTex, i.uv.zw).rgb;

    // the closer outside, the finer the hair.
    float finAlpha = clamp(furNoise - (Furlayer * Furlayer) * _FurDensity, 0, 1);

    return fixed4(finCol, finAlpha);
}
