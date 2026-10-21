using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MotionBlurEffect : MonoBehaviour
{
    public Shader motionBlurShader;
    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    private Material blurMaterial;
    private RenderTexture lastFrameTexture;

    private Material Material
    {
        get
        {
            if (blurMaterial == null && motionBlurShader != null)
            {
                blurMaterial = new Material(motionBlurShader);
                blurMaterial.hideFlags = HideFlags.DontSave; //prevent the material from being saved to the scene
            }
            return blurMaterial;
        }
    }
    private void OnDisable()
    {
        if (lastFrameTexture != null)
        {
            DestroyImmediate(lastFrameTexture);
            lastFrameTexture = null;
        }
        if (blurMaterial != null)
        {
            DestroyImmediate(blurMaterial);
            blurMaterial = null;
        }
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        if (lastFrameTexture == null || lastFrameTexture.width != source.width || lastFrameTexture.height != source.height)
        {
            if (lastFrameTexture != null)
            {
                DestroyImmediate(lastFrameTexture);
            }
            lastFrameTexture = new RenderTexture(source.width, source.height, 0);
            lastFrameTexture.hideFlags = HideFlags.DontSave;
            Graphics.Blit(source, lastFrameTexture);
        }

        //deliver references
        Material.SetFloat("_BlurAmount", blurAmount);
        Material.SetTexture("_LastFrameTex", lastFrameTexture);

        RenderTexture tempRT = RenderTexture.GetTemporary(source.width, source.height, 0);
        Graphics.Blit(source, tempRT, Material);
        Graphics.Blit(tempRT, lastFrameTexture);
        Graphics.Blit(tempRT, destination);
        RenderTexture.ReleaseTemporary(tempRT);

    }
}
