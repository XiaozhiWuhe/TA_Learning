
using UnityEngine;

public class CrackEffectController : MonoBehaviour
{
    [SerializeField]
    private SceneCrackEffect crackEffect;

    private void Update()
    {
        if (crackEffect == null) { return; }
        if (Input.GetMouseButtonDown(0)) { crackEffect.Play(); }
    }
}
