using System.Collections;
using UnityEngine;

public class ScreenFragmentController : MonoBehaviour
{
    public Camera cameraA;
    public Camera cameraB;
    public SceneCrackEffect crackEffect;
    public Transform shardsRoot;
    private Rigidbody[] shards;
    public Transform explosionCenter;
    public float explosionForce = 8f;
    public float explosionRadius = 3f;
    public float upwardsModifier = 0.3f;
    public float explosionDelay = 0.15f;
    public float blackScreenDelay = 2.5f;
    private bool hasExploded;
    public RenderTexture snapshotTexture;
    private void Awake()
    {
        //get rigidbody each fragment
        RefreshFragments();

        //close camera b
        if (cameraB != null)
        {
            cameraB.enabled = false;
        }

        foreach (Rigidbody rb in shards)
        {
            if (rb == null) continue;

            rb.isKinematic = true;
            rb.useGravity = false;
        }
    }

    public void RefreshFragments()
    {
        if (shardsRoot == null)
        {
            shards = System.Array.Empty<Rigidbody>();
            return;
        }

        shards = shardsRoot.GetComponentsInChildren<Rigidbody>(true);
    }

    private void OnEnable()
    {
        if (crackEffect != null)
        {
            crackEffect.OnCrackCompleted += HandleCrackCompleted;
        }
    }

    private void OnDisable()
    {
        if (crackEffect != null)
        {
            crackEffect.OnCrackCompleted -= HandleCrackCompleted;
        }
    }

    private void HandleCrackCompleted()
    {
        if (hasExploded) return;

        hasExploded = true;
        StartCoroutine(FragmentSequence());
    }

    private IEnumerator FragmentSequence()
    {
        yield return new WaitForEndOfFrame();

        if (explosionDelay > 0f)
        {
            yield return new WaitForSeconds(explosionDelay);
        }

        if (cameraA != null)
        {
            cameraA.enabled = false;
        }
        ApplySnapshotToShards();

        if (cameraB != null)
        {
            cameraB.enabled = true;
        }
        else
        {
            yield break;
        }

        Vector3 center = explosionCenter != null
            ? explosionCenter.position
            : cameraB.transform.position
                + cameraB.transform.forward * 0.5f;

        //active the physical effect
        foreach (Rigidbody rb in shards)
        {
            if (rb == null) continue;

            rb.isKinematic = false;
            rb.useGravity = true;

            rb.AddExplosionForce(
                explosionForce,
                center,
                explosionRadius,
                upwardsModifier,
                ForceMode.Impulse
            );
        }

        if (blackScreenDelay > 0f)
        {
            yield return new WaitForSeconds(blackScreenDelay);
        }

        //hide fragments
        foreach (Rigidbody rb in shards)
        {
            if (rb == null) continue;

            Renderer[] renderers =
                rb.GetComponentsInChildren<Renderer>(true);
            foreach (Renderer r in renderers)
            {
                r.enabled = false;
            }

            rb.isKinematic = true;
            rb.useGravity = false;
        }
    }
    private void ApplySnapshotToShards()
    {
        if (snapshotTexture == null)
        {
            Debug.LogError("Snapshot Texture 尚未设置！");
            return;
        }

        if (shardsRoot == null) return;

        Renderer[] renderers =
            shardsRoot.GetComponentsInChildren<Renderer>(true);

        foreach (Renderer renderer in renderers)
        {
            Material mat = renderer.material;

            if (mat != null)
            {
                mat.mainTexture = snapshotTexture;
            }
        }
    }
}