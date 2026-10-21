using UnityEngine;

/// <summary>
/// Optional UV helper for a custom rectangular mesh in the local XY plane.
/// Run Setup Screen UVs from the component context menu only if the UVs need setup.
/// </summary>
[RequireComponent(typeof(MeshFilter))]
public class ScreenMeshUVSetup : MonoBehaviour
{
    [ContextMenu("Setup Screen UVs")]
    public void SetupUVs()
    {
        MeshFilter mf = GetComponent<MeshFilter>();
        Mesh source = mf.sharedMesh;
        if (source == null)
        {
            Debug.LogError("No mesh assigned to MeshFilter.", this);
            return;
        }

        Bounds bounds = source.bounds;
        if (Mathf.Approximately(bounds.size.x, 0f) ||
            Mathf.Approximately(bounds.size.y, 0f))
        {
            Debug.LogError("Mesh has zero width/height in local XY. For an XZ mesh, use Z for V.", this);
            return;
        }

        Mesh mesh = Instantiate(source);
        mesh.name = source.name + "_ScreenUV";
        Vector3[] vertices = mesh.vertices;
        Vector2[] uv = new Vector2[vertices.Length];

        for (int i = 0; i < vertices.Length; i++)
        {
            uv[i] = new Vector2(
                Mathf.InverseLerp(bounds.min.x, bounds.max.x, vertices[i].x),
                Mathf.InverseLerp(bounds.min.y, bounds.max.y, vertices[i].y));
        }

        mesh.uv = uv;
        mf.sharedMesh = mesh;
        Debug.Log("UVs set. Verify with a grid/checker texture before RayFire shattering.", this);
    }
}
