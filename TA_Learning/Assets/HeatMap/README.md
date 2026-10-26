## 大致思路

* 首先生成随机的几个热度中心点 :
  * 以数组的形式分别传递坐标到 shader;
  * 假设热度图平面在xy平面，即z＝0；
  * 注意坐标要从local转到world：
  ```c#
  Vector3 localPos = new Vector3(Random.Range(minX, maxX), Random.Range(minY, maxY), 0f);
  Vector3 worldPos = transform.TransformPoint(localPos); 
  pointPoses[i] = new Vector4(worldPos.x, worldPos.y, worldPos.z, 0f);
  ```

  * 以及对应属性（半径、透明度）也传递到 shader：
  ```c#
  pointProperties[i] = new Vector4(Random.Range(minRadius, maxRadius), Random.Range(minAlpha, maxAlpha), 0f, 0f);
  ```
  * 注意到这里的 pointPoses[] 实际只需要传递xyz，应该使用三维数组即可、
  * 同理，而 pointProperties[i] 只要使用二维数组。
  * 但是这里却使用 Vector4 来储存它们。
  * 原因在于：
  * ```void Material.SetVectorArray(string name, Vector4[] values)```

* 最后在 Shader 中，接受脚本传递的数组后：
  * 计算 mesh 表面的像素到热度中心的点的距离 d，
  * 对半径 r 与 d 进行 对于 alpha 的线性运算：
  ```hlsl
  float hi = 1 - saturate(di / ri);
  h += hi * _PointProperties[i];
  ```