using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class DownSamplingRenderPass : ScriptableRenderPass
{
    private const string _commandBufferName = nameof(DownSamplingRenderPass);
    private const int _renderTextureId = 0;
    private RenderTargetIdentifier _currentTarget;
    private int _downSample = 5;
    /*
    constructor
    */
    public DownSamplingRenderPass(){
        renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }
    /*
    execute
    */
    public override void Execute(ScriptableRenderContext context, ref RenderingData rd){
        // Debug.Log("current target = " + _currentTarget.ToString());
        var cmd = CommandBufferPool.Get(_commandBufferName);
        var cameraData = rd.cameraData;
        int width = cameraData.camera.scaledPixelWidth / _downSample;
        int height = cameraData.camera.scaledPixelHeight / _downSample;

        // Debug.Log("downsample = " + _downSample.ToString());
        // Debug.Log("width = " + width.ToString());
        // Debug.Log("height = " + height.ToString());
        cmd.GetTemporaryRT(_renderTextureId, width, height, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(_currentTarget, _renderTextureId);
        cmd.Blit(_renderTextureId, _currentTarget);
        cmd.ReleaseTemporaryRT(_renderTextureId);
        context.ExecuteCommandBuffer(cmd);
        context.Submit();
        CommandBufferPool.Release(cmd);
    }

    /*
    set function
    */
    public void SetParam(RenderTargetIdentifier renderTarget, int downSample){
        _currentTarget = renderTarget;
        _downSample = downSample;
        if(_downSample <= 0)
            _downSample = 1;
    }
}
