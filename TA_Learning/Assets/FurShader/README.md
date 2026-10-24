# 一编

## 大致思路

* 首先我们通过使用多个pass来渲染毛发长度。
  * 对于毛发的顶点，随着渲染的层数增加沿法线增加一个length的距离得到新的点，然后渲染这个点。
  * n个pass就渲染n层这样的点，我们就能得到对于某个顶点向外扩n×length的毛发长度。
  * 以下是对于这样的点的计算方式：
    ```hlsl
    float3 newPoint = v.vertex.xyz + v.normal * _FurLength * Furlayer;
    ```
    * Furlayer表示当前层/总层，分的越细毛发就会越精细。
  * 然后我们使用一张噪声贴图决定哪里应该生成毛发。

* 此外在渲染毛发之前还应该对表面皮肤进行渲染。
  * 直接采样皮肤贴图即可。

* 光照模型采用Blinn-Phong模型。

* 接下来我们通过控制丢失一部分毛发的像素来呈现出毛发密度的视觉效果。
  * 毛发长度越靠近外面（即越靠后的pass）越薄（即alpha值越小）：
  ```hlsl
  float finAlpha = clamp(tex2D(_FurTex, i.uv.zw).rgb - (Furlayer * Furlayer) * _FurDensity, 0, 1);
  ```
  * 其中FurDensity这个系数用来控制实际应该丢失的像素的强度。

* 然后实现一下外力影响毛发偏移。
  * 假设我们现在有的是重力和风力（先这么称呼）。
  * 对于多个世界空间外力，我们需要计算它们的合力：
  ```hlsl
  float3 worldForce = _WindForce.xyz + _GravityForce.xyz;
  ```
  * 然后从世界空间转为物体空间：
  ```hlsl
  float3 objectForce = mul(unity_WorldToObject, float4(worldForce, 0)).xyz;
  ```
  * 限制大小然后把这个值加回顶点作为偏移：
  ```hlsl
  float3 force = clamp(objectForce, -1, 1);
  newPoint .+= force * pow(Furlayer, 3) * _FurLength;
  ```
  * 然后我们通过噪声贴图用来计算风力。
  * 我们的思路是：
  1. 根据顶点在世界空间的坐标，计算对应噪声贴图的uv:
  ```hlsl
  float2 noiseUV = o.worldPos.xz * _WindNoiseScale;
  ```
  2. 让uv坐标随时间移动:
  ```hlsl
  noiseUV -= windDirXZ * _Time.y * _WindSpeed;
  ```
  3. 采样噪声值，用于上述的合力部分:
  ```hlsl
  float noise = tex2Dlod(_WindNoiseTex, float4(noiseUV, 0, 0)).r;
  ```