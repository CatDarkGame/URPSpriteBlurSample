using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace CatDarkGame.RendererFeature
{
    public class LayerFilterRendererPass_Prepass : ScriptableRenderPass
    {
        private const string k_ProfilingSamplerName = "LayerFilterPrepass";
        private const string k_RenderTextureName = "_LayerFilterPrepassBufferRT";
        private const string k_TexturePropertyName = "_LayerFilterPrepassBufferTex";

        public RenderTargetHandle prepassBufferRTH;
        private ProfilingSampler m_ProfilingSampler;

        private LayerMask _layerMask;
        private ShaderTagId _shaderTagId;


        public LayerFilterRendererPass_Prepass(RenderPassEvent passEvent, LayerMask layerMask, ShaderTagId shaderTagId)
        {
            renderPassEvent = passEvent;
            _layerMask = layerMask;
            _shaderTagId = shaderTagId;

            m_ProfilingSampler = new ProfilingSampler(k_ProfilingSamplerName);
        }

        public void Setup(ref RenderTargetHandle source, RenderTargetIdentifier renderTargetDestination)
        {
            source.Init(k_RenderTextureName);
            prepassBufferRTH = source;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // Prepass �������� ���ο� �������� ���� (���� colorpass�� �������ϴ°� �ƴ� ���� ���ۿ� �������ϱ� ����)
            RenderTextureDescriptor renderTextureDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            renderTextureDescriptor.colorFormat = RenderTextureFormat.RGB111110Float;
            renderTextureDescriptor.msaaSamples = 1;
            cmd.GetTemporaryRT(prepassBufferRTH.id, renderTextureDescriptor);
            cmd.SetGlobalTexture(k_TexturePropertyName, prepassBufferRTH.Identifier());

            ConfigureClear(ClearFlag.All, Color.black);     // Pass ������ ������ ������ Clear ���� (������ �����ӿ� Sprite ������)
            ConfigureTarget(new RenderTargetIdentifier(prepassBufferRTH.Identifier(), 0, CubemapFace.Unknown, -1));     // Pass ������ ��� ����
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(prepassBufferRTH.id);
        }


        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
            using (new UnityEngine.Rendering.ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                DrawingSettings drawSetting = CreateDrawingSettings(_shaderTagId, ref renderingData, SortingCriteria.CommonTransparent);
                FilteringSettings filterSetting = new FilteringSettings(RenderQueueRange.transparent, _layerMask);
                context.DrawRenderers(renderingData.cullResults, ref drawSetting, ref filterSetting);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}