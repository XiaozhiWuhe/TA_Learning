using UnityEngine;
using UnityEditor;
using System.Collections;
public class RenderCubeMap : ScriptableWizard
{
public Transform renderPosition;
public Cubemap cubemap;
void OnWizardUpdate()
{
isValid = (renderPosition != null) && (cubemap != null);
}
void OnWizardCreate()
{
GameObject go = new GameObject("CubemapCam");
go.AddComponent<Camera>();
go.transform.position = renderPosition.position;
go.GetComponent<Camera>().RenderToCubemap(cubemap);
DestroyImmediate(go);
}
[MenuItem("GameObject/RenderCubemap")]
static void RenderCubemapWizard()
{
ScriptableWizard.DisplayWizard<RenderCubeMap>(
"RenderCubemap", " 立即渲染 ");
}
}