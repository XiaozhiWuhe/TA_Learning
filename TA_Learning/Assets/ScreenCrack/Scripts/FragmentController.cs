using UnityEngine;

public class FragmentationController : MonoBehaviour
{
    [Header("Input")]
    [SerializeField]
    private KeyCode triggerKey = KeyCode.Space;

    [Header("Fragmentation")]
    [Tooltip("碎片从触发到完全消失的时间")]
    [SerializeField]
    private float lifetime = 1.5f;

    [Tooltip("爆炸力度")]
    [SerializeField]
    private float explosionForce = 3.0f;

    [Tooltip("重力大小")]
    [SerializeField]
    private float gravity = 9.81f;

    [Tooltip("爆炸中心。为空时使用当前模型中心")]
    [SerializeField]
    private Transform explosionCenter;

    private Renderer targetRenderer;
    private Material material;

    private float breakTime;
    private bool isBreaking;

    private static readonly int BreakTimeID =
        Shader.PropertyToID("_BreakTime");

    private static readonly int ExplosionCenterID =
        Shader.PropertyToID("_ExplosionCenter");

    private static readonly int GravityID =
        Shader.PropertyToID("_Gravity");

    private static readonly int ExplosionForceID =
        Shader.PropertyToID("_ExplosionForce");

    // =========================================================
    // Unity
    // =========================================================

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();

        if (targetRenderer == null)
        {
            Debug.LogError(
                $"[{nameof(FragmentationController)}] 没有找到 Renderer。",
                this
            );

            enabled = false;
            return;
        }

        // 创建 Material 实例，避免修改共享材质
        material = targetRenderer.material;

        ResetFragmentation();
    }

    private void Update()
    {
        if (Input.GetKeyDown(triggerKey))
        {
            TriggerExplosion();
        }

        if (!isBreaking)
            return;

        breakTime += Time.deltaTime;

        material.SetFloat(
            BreakTimeID,
            breakTime
        );

        if (breakTime >= lifetime)
        {
            breakTime = lifetime;

            material.SetFloat(
                BreakTimeID,
                breakTime
            );

            isBreaking = false;
        }
    }

    // =========================================================
    // Trigger
    // =========================================================

    public void TriggerExplosion()
    {
        breakTime = 0.0f;
        isBreaking = true;

        // -----------------------------------------------------
        // 设置 Shader 参数
        // -----------------------------------------------------

        Vector3 center;

        if (explosionCenter != null)
        {
            center = explosionCenter.position;
        }
        else
        {
            center = targetRenderer.bounds.center;
        }

        material.SetVector(
            ExplosionCenterID,
            center
        );

        material.SetFloat(
            GravityID,
            gravity
        );

        material.SetFloat(
            ExplosionForceID,
            explosionForce
        );

        material.SetFloat(
            BreakTimeID,
            0.0f
        );

        // -----------------------------------------------------
        // 切换到透明碎片模式
        // -----------------------------------------------------

        SetTransparentMode();
    }

    // =========================================================
    // Opaque Mode
    // =========================================================

    private void SetOpaqueMode()
    {
        // Render Queue
        material.renderQueue =
            (int)UnityEngine.Rendering.RenderQueue.Geometry;

        // RenderType
        material.SetOverrideTag(
            "RenderType",
            "Opaque"
        );

        // Alpha Blend Off
        material.SetInt(
            "_SrcBlend",
            (int)UnityEngine.Rendering.BlendMode.One
        );

        material.SetInt(
            "_DstBlend",
            (int)UnityEngine.Rendering.BlendMode.Zero
        );

        material.SetInt(
            "_ZWrite",
            1
        );

        material.DisableKeyword("_ALPHABLEND_ON");

        material.SetFloat(
            "_Alpha",
            1.0f
        );
    }

    // =========================================================
    // Transparent Mode
    // =========================================================

    private void SetTransparentMode()
    {
        // Render Queue
        material.renderQueue =
            (int)UnityEngine.Rendering.RenderQueue.Transparent;

        // RenderType
        material.SetOverrideTag(
            "RenderType",
            "Transparent"
        );

        // Alpha Blend
        material.SetInt(
            "_SrcBlend",
            (int)UnityEngine.Rendering.BlendMode.SrcAlpha
        );

        material.SetInt(
            "_DstBlend",
            (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha
        );

        material.SetInt(
            "_ZWrite",
            0
        );

        material.EnableKeyword("_ALPHABLEND_ON");
    }

    // =========================================================
    // Reset
    // =========================================================

    public void ResetFragmentation()
    {
        breakTime = 0.0f;
        isBreaking = false;

        // -----------------------------------------------------
        // Shader 参数恢复
        // -----------------------------------------------------

        material.SetFloat(
            BreakTimeID,
            0.0f
        );

        material.SetFloat(
            GravityID,
            gravity
        );

        material.SetFloat(
            ExplosionForceID,
            explosionForce
        );

        Vector3 center;

        if (explosionCenter != null)
        {
            center = explosionCenter.position;
        }
        else
        {
            center = targetRenderer.bounds.center;
        }

        material.SetVector(
            ExplosionCenterID,
            center
        );

        material.SetFloat(
            "_Alpha",
            1.0f
        );

        // -----------------------------------------------------
        // 恢复普通 Opaque
        // -----------------------------------------------------

        SetOpaqueMode();
    }

    // =========================================================
    // Destroy
    // =========================================================

    private void OnDestroy()
    {
        if (material != null)
        {
            Destroy(material);
        }
    }
}