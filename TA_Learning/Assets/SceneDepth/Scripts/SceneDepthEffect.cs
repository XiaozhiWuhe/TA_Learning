using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class SceneDepthEffect : MonoBehaviour
{
    [Header("Shader Setting")]
    public Material dosMaterial;

    [Header("Parameters")]
    public float focusDistance = 10.0f;
    public float focusRange = 5.0f;
    [Range(1, 4)]
    public int downSample = 1;
    [Range(1, 4)]
    public int blurIterations = 2;
    [Range(0.1f, 3.0f)]
    public float blurRadius = 1.0f;

    private Camera cam;

    void OnEnable()
    {
        cam = GetComponent<Camera>();
        // Enable depth texture mode to allow the shader to access depth information
        cam.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (dosMaterial == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        int rtW = source.width / downSample;
        int rtH = source.height / downSample;

        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
        RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
        buffer0.filterMode = FilterMode.Bilinear;
        buffer1.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source, buffer0);
        for (int i = 0; i < blurIterations; i++)
        {
            dosMaterial.SetFloat("_BlurSize", (1.0f + i * 0.5f) * blurRadius);
            // Pass 0: (buffer0 -> buffer1)
            Graphics.Blit(buffer0, buffer1, dosMaterial, 0);
            // Pass 1: (buffer1 -> buffer0)
            Graphics.Blit(buffer1, buffer0, dosMaterial, 1);
        }
        dosMaterial.SetFloat("_FocusDistance", focusDistance);
        dosMaterial.SetFloat("_FocusRange", focusRange);
        dosMaterial.SetTexture("_BlurTex", buffer0);
        Graphics.Blit(source, destination, dosMaterial, 2);
        dosMaterial.SetTexture("_BlurTex", null);

        RenderTexture.ReleaseTemporary(buffer0);
        RenderTexture.ReleaseTemporary(buffer1);
    }
}