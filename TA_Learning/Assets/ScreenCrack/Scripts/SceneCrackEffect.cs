using System;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class SceneCrackEffect : MonoBehaviour
{
    public Shader CrackShader;
    public Texture2D CrackMap1;
    public Texture2D CrackMap2;
    public Texture2D CrackMap3;

    [Range(0, 1f)]
    public float CrackThreshold = 1f;

    [Range(0, 0.5f)]
    public float CrackSoftness = 0.5f;

    [Range(0, 1f)]
    public float Progress = 0f;

    [Range(0, 1f)]
    public float HighLightProgress = 0f;

    [Range(0, 5f)]
    public float HighLightIntensity = 1f;

    [Range(0, 2f)]
    public float HighLightWidth = 1f;

    [Range(0, 1f)]
    public float CrackOpacity = 1f;

    [Range(0, 3)]
    private int HighLightStage = 0;
    public Color CrackColor = new Color(0.9f, 0.9f, 1f, 1f);
    public Color HighLightColor = new Color(0.9f, 0.9f, 1f, 1f);
    private bool isPlaying = false;

    [Header("Time")]
    private float Timer = 0f;
    private float DelayBeforeStart = 0.1f;
    public float PauseDuration = 0.2f;
    public float Duration = 1f;
    private float TotalDuration => DelayBeforeStart + PauseDuration * 2 + Duration * 3;

    public System.Action OnCrackCompleted;
    [Header("Screen Shatter")]
    public RenderTexture SnapshotTarget;

    private Material rtMaterial;
    private void OnEnable()
    {
        ApplyParameters();
        CreateMaterials();
    }
    private void Start()
    {
        if (Application.isPlaying) { Play(); }
    }
    private void OnDisable()
    {
        isPlaying = false;
        if (rtMaterial != null)
        {
            if (Application.isPlaying) { Destroy(rtMaterial); }
            else { DestroyImmediate(rtMaterial); }
            rtMaterial = null;
        }
    }

    private void Update()
    {
        if (!Application.isPlaying)
        {
            ApplyParameters();
            return;
        }

        if (!isPlaying)
            return;

        Timer += Time.deltaTime;

        // 延迟开始
        if (Timer < DelayBeforeStart)
        {
            Progress = 0f;
            HighLightProgress = 0f;
            ApplyParameters();
            return;
        }

        float t = Timer - DelayBeforeStart;

        if (t < Duration)
        {
            Progress = Mathf.Clamp01(t / Duration) / 3f;
            HighLightProgress = 0f;
            HighLightStage = 0;
            ApplyParameters();
            return;
        }

        t -= Duration;
        if (t < PauseDuration)
        {
            Progress = 1f / 3f;
            HighLightStage = 1;
            float normalizedTime = Mathf.Clamp01(t / PauseDuration);
            HighLightProgress = Mathf.SmoothStep(0f, 1f, normalizedTime);
            ApplyParameters();
            return;
        }

        t -= PauseDuration;
        if (t < Duration)
        {
            Progress = (1f + Mathf.Clamp01(t / Duration)) / 3f;
            HighLightStage = 1;
            ApplyParameters();
            return;
        }

        t -= Duration;
        if (t < PauseDuration)
        {
            Progress = 2f / 3f;
            HighLightStage = 2;
            float normalizedTime = Mathf.Clamp01(t / PauseDuration);
            HighLightProgress = Mathf.SmoothStep(0f, 1f, normalizedTime);
            ApplyParameters();
            return;
        }

        t -= PauseDuration;
        if (t < Duration)
        {
            Progress = (2f + Mathf.Clamp01(t / Duration)) / 3f;
            HighLightStage = 2;
            ApplyParameters();
            return;
        }

        Progress = 1f;
        HighLightStage = 3;
        HighLightProgress = 1f;
        isPlaying = false;
        ApplyParameters();

        OnCrackCompleted?.Invoke();
    }

    public void ApplyParameters()
    {
        if (rtMaterial == null)
        {
            return;
        }
        rtMaterial.SetTexture("_CrackMap1", CrackMap1);
        rtMaterial.SetTexture("_CrackMap2", CrackMap2);
        rtMaterial.SetTexture("_CrackMap3", CrackMap3);
        rtMaterial.SetFloat("_CrackThreshold", CrackThreshold);
        rtMaterial.SetFloat("_CrackSoftness", CrackSoftness);
        rtMaterial.SetFloat("_CrackOpacity", CrackOpacity);
        rtMaterial.SetColor("_CrackColor", CrackColor);
        rtMaterial.SetFloat("_Progress", Progress);
        rtMaterial.SetColor("_HighLightColor", HighLightColor);
        rtMaterial.SetFloat("_HighLightIntensity", HighLightIntensity);
        rtMaterial.SetFloat("_HighLightWidth", HighLightWidth);
        rtMaterial.SetFloat("_HighLightStage", HighLightStage);
        rtMaterial.SetFloat("_HighLightProgress", HighLightProgress);
    }
    public void CreateMaterials()
    {
        if (CrackShader == null) { return; }
        if (!CrackShader.isSupported) { return; }
        if (rtMaterial != null && rtMaterial.shader == CrackShader) { return; }
        if (rtMaterial != null)
        {
            if (Application.isPlaying) { Destroy(rtMaterial); }
            else { DestroyImmediate(rtMaterial); }
        }
        rtMaterial = new Material(CrackShader);
        rtMaterial.hideFlags = HideFlags.HideAndDontSave;
    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (rtMaterial == null)
        {
            Graphics.Blit(source, destination);
            if (SnapshotTarget != null) { Graphics.Blit(source, SnapshotTarget); }
            return;
        }

        //Input crack
        Graphics.Blit(source, destination, rtMaterial);

        //capture the scene
        if (SnapshotTarget != null) { Graphics.Blit(source, SnapshotTarget, rtMaterial); }
    }

    public void Play()
    {
        Timer = 0f;
        Progress = 0f;
        HighLightStage = 0;
        HighLightProgress = 0f;
        isPlaying = true;
        ApplyParameters();
    }

    public void SetProgress(float value)
    {
        Progress = Mathf.Clamp01(value);
        Timer = Mathf.Clamp(Progress * TotalDuration, 0, TotalDuration);
        isPlaying = false;
        ApplyParameters();
    }
}
