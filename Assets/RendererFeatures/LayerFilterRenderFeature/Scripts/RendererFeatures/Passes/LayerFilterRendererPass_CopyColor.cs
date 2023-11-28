using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;

namespace CatDarkGame.RendererFeature
{
    public class LayerFilterRendererPass_CopyColor : ScriptableRenderPass
    {
        private const string PASS_NAME = "CustomGrabPass";

        private RenderTargetIdentifier _source;
        private RenderTargetHandle _destination;

        private Downsampling _downsamplingMethod;
        private string _globalProperty;

        public LayerFilterRendererPass_CopyColor(RenderPassEvent passEvent)
        {
            renderPassEvent = passEvent;
        }

        public void Setup(RenderTargetIdentifier source, RenderTargetHandle destination)
        {
            ConfigureInput(ScriptableRenderPassInput.Color);
            _destination = destination;
            _source = source;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            RenderTextureDescriptor renderTextureDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            renderTextureDescriptor.colorFormat = RenderTextureFormat.ARGB32;
            renderTextureDescriptor.msaaSamples = 1;
            cmd.GetTemporaryRT(_destination.id, renderTextureDescriptor);
            ConfigureTarget(new RenderTargetIdentifier(_destination.Identifier(), 0, CubemapFace.Unknown, -1));
            //ConfigureClear(ClearFlag.All, Color.black);
        }

       /* public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            RenderTextureDescriptor descriptor = cameraTextureDescriptor;
            descriptor.msaaSamples = 1;
            descriptor.depthBufferBits = 0;
         
            cmd.GetTemporaryRT(_destination.id, descriptor, FilterMode.Bilinear);
            cmd.SetGlobalTexture(_globalProperty, _destination.Identifier());
        }*/

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(PASS_NAME);
             context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            Blit(cmd, _source, _destination.Identifier());
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(_destination.id);
        }
    }
}