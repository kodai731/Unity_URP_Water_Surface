using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DownSamplingRenderFeature : ScriptableRendererFeature
{
    public int _downSample = 100;
    private DownSamplingRenderPass _renderPass;
    public override void Create()
    {
        _renderPass = new DownSamplingRenderPass();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        _renderPass.SetParam(renderer.cameraColorTarget, _downSample);
        renderer.EnqueuePass(_renderPass);
    }
}
