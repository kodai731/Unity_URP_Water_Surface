using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DownSamplingAnimation : MonoBehaviour
{
    [SerializeField] 
    private DownSamplingRenderFeature _feature;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var temp = (Mathf.Sin(4f * Time.frameCount * Mathf.PI / 180f) + 1f) / 2f;
        var value = temp * 120f;
        _feature._downSample = (int)value;
    }
}
