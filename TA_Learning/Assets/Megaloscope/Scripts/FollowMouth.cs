using UnityEngine;

public class FollowMouse : MonoBehaviour
{
    [Header("Set")]
    [Tooltip("Distance from the camera to the object in world units.")]
    public float distanceFromCamera = 5f;

    private Camera mainCamera;

    void Start()
    {
        //get the main camera
        mainCamera = Camera.main;
    }

    void Update()
    {
        if (mainCamera == null) return;

        // get the mouse position in screen space
        Vector3 mouseScreenPos = Input.mousePosition;

        // set the z position to the distance from the camera
        mouseScreenPos.z = distanceFromCamera;

        // convert the screen position to world position
        Vector3 worldPos = mainCamera.ScreenToWorldPoint(mouseScreenPos);
        transform.position = worldPos;
    }
}