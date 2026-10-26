using System.Collections;
using UnityEngine;

public class HeatMap : MonoBehaviour
{
    public int pointCount = 1;
    public Material heatMat;
    private Vector4[] pointPoses;
    private Vector4[] pointProperties;

    private void Start()
    {
        if (heatMat == null)
        {
            Debug.LogError("heatMat Invalid");
            enabled = false;
            return;
        }
        pointCount = Mathf.Clamp(pointCount, 1, 100);
        pointPoses = new Vector4[pointCount];
        pointProperties = new Vector4[pointCount];

        for (int i = 0; i < pointCount; i++)
        {
            Vector3 localPos = new Vector3(Random.Range(-4.5f, 4.5f), 0f, Random.Range(-4.5f, 4.5f));
            Vector3 worldPos = transform.TransformPoint(localPos);
            pointPoses[i] = new Vector4(worldPos.x, worldPos.y, worldPos.z, 0f);
            pointProperties[i] = new Vector4(Random.Range(0.5f, 2f), Random.Range(0.25f, 1f), 0f, 0f);
        }
        heatMat.SetVectorArray("_PointPoses", pointPoses);
        heatMat.SetVectorArray("_Properties", pointProperties);
        heatMat.SetInt("_Points_Count", pointCount);
    }
}
