using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using Unity.VisualScripting;

public class ReplaceShader : EditorWindow
{
    private Shader targetShader;

    // get a window.
    [MenuItem("Tools/Replace Shader")]
    private static void GetWindow()
    {
        GetWindow<ReplaceShader>("ReplaceShaderTool");
    }
    // draw the gui.
    private void OnGUI()
    {
        EditorGUILayout.Space(10);
        // select shader
        targetShader = (Shader)EditorGUILayout.ObjectField
        (
            "Target Shader",
            targetShader,
            typeof(Shader),
            false
        );
        List<Material> materials = GetSelectedMaterials();
        EditorGUILayout.LabelField("Selected Material:" + materials.Count);
        EditorGUILayout.Space(10);
        using (new EditorGUI.DisabledScope(targetShader == null || materials.Count == 0))
        {
            if (GUILayout.Button("Apply"))
            {
                ReplaceShaders(materials);
            }
        }
    }
    // get selected materials.
    private List<Material> GetSelectedMaterials()
    {
        List<Material> materials = new List<Material>();

        // 1. 获取 Project 中直接选中的 Material
        foreach (Object obj in Selection.objects)
        {
            Material mat = obj as Material;
            if (mat != null && EditorUtility.IsPersistent(mat))
            {
                if (!materials.Contains(mat))
                {
                    materials.Add(mat);
                }
            }
        }

        // 2. 获取 Hierarchy 中选中的 GameObject 所引用的 Material
        foreach (GameObject go in Selection.gameObjects)
        {
            if (go == null) continue;

            Renderer[] renderers =
                go.GetComponentsInChildren<Renderer>(true);

            foreach (Renderer renderer in renderers)
            {
                foreach (Material mat in renderer.sharedMaterials)
                {
                    if (mat != null && !materials.Contains(mat))
                    {
                        materials.Add(mat);
                    }
                }
            }
        }

        return materials;
    }

    // replace the alternative shader of the selected materials with new one.
    private void ReplaceShaders(List<Material> materials)
    {
        // the third check: you should have the selected target.
        if (targetShader == null)
        {
            Debug.LogError("Please choose the shader you want to change");
            return;
        }
        if (materials.Count == 0)
        {
            Debug.LogError("Please choose the materials you want to change");
            return;
        }
        // deliver mat to toReplace(material) if its shader isnt the target one
        List<Material> toReplace = new List<Material>();

        foreach (Material mat in materials)
        {
            // the final check: if it is really need to replace.
            if (mat.shader == targetShader) { continue; }
            else { toReplace.Add(mat); }
        }
        // it can allow u to undo operation this time.
        Undo.RecordObjects(
            toReplace.ToArray(),
            "Replace Material Shader"
        );
        //begin to replace:
        foreach (Material mat in toReplace)
        {
            if (mat == null) { return; }
            mat.shader = targetShader;
            EditorUtility.SetDirty(mat);
        }
        AssetDatabase.SaveAssets();
    }
}
