using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class Pixelization : MonoBehaviour
{
    public Material pixMaterial;
    [Range(0, 256)]
    public float pixelSize = 64;
    private readonly int PixelSizeID = Shader.PropertyToID("_PixelSize");

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (pixMaterial == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        pixMaterial.SetFloat(PixelSizeID, pixelSize);

        int width = source.width;
        int height = source.height;
        RenderTexture tempRT = RenderTexture.GetTemporary(width, height, 0, source.format);
        Graphics.Blit(source, tempRT, pixMaterial);
        Graphics.Blit(tempRT, destination);
        RenderTexture.ReleaseTemporary(tempRT);
    }
}
