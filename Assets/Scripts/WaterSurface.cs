using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterSurface : MonoBehaviour
{
    private MeshCollider _meshCollider;
    public struct CollisionInfo{
        public Vector3 collisionPoint;
    };
    // Start is called before the first frame update
    void Start()
    {
        _meshCollider = GetComponent<MeshCollider>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnCollisionEnter(Collision other) {
        GameObject otherObject = other.gameObject;
        ContactPoint[] contactPoints = other.contacts;
        Debug.Log("contact points num = " + contactPoints.Length.ToString());
    }
}
