using Codice.Client.Common.GameUI.Checkin;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEngine;
using UnityEditor.ShaderGraph;
using UnityEditor.ShaderGraph.Drawing;
using UnityEditor.Rendering;
using UnityEditor.Rendering.BuiltIn;
using UnityEngine.Rendering;

namespace CatDarkGame.Editor
{
    public class Sprite_Master_GUI : ShaderGUI
    {
        public enum SurfaceType
        {
            Opaque,
            AlphaTest,
            Transparent
        }

        public enum ZWriteControl
        {
            Auto,
            ForceEnabled,
            ForceDisabled
        }

        internal static class Property
        {
            public static readonly string SurfaceType = "_Surface";
            public static readonly string BlendMode = "_Blend";
            public static readonly string AlphaClip = "_AlphaClip";
            public static readonly string SrcBlend = "_SrcBlend";
            public static readonly string DstBlend = "_DstBlend";
            public static readonly string ZWrite = "_ZWrite";
            public static readonly string CullMode = "_Cull";
      
            public static readonly string ZTest = "_ZTest";
            public static readonly string ZWriteControl = "_ZWriteControl";
        }

        protected class Styles
        {
            public static readonly string[] surfaceTypeNames = Enum.GetNames(typeof(SurfaceType));
            public static readonly string[] zwriteNames = Enum.GetNames(typeof(ZWriteControl));

            public static readonly GUIContent surfaceType = EditorGUIUtility.TrTextContent("Surface Type",
                "Select a surface type for your texture. Choose between Opaque or Transparent.");

            public static readonly GUIContent zwriteText = EditorGUIUtility.TrTextContent("Depth Write",
                "Controls whether the shader writes depth.  Auto will write only when the shader is opaque.");

            public static readonly GUIContent alphaClipText = EditorGUIUtility.TrTextContent("Alpha Clipping",
               "Makes your Material act like a Cutout shader. Use this to create a transparent effect with hard edges between opaque and transparent areas.");

            public static readonly GUIContent alphaClipThresholdText = EditorGUIUtility.TrTextContent("Threshold",
                "Sets where the Alpha Clipping starts. The higher the value is, the brighter the  effect is when clipping starts.");



            public static readonly GUIContent mainTex = EditorGUIUtility.TrTextContent("Base Map",
                    "(Description)");
            public static readonly GUIContent color = EditorGUIUtility.TrTextContent("Tint Color",
                    "(Description)");
        }


        public bool m_FirstTimeApply = true;
        private bool m_isChangeRenderQueue = false;
        private const bool _isPerRendererData = true;   // Material에서 직접 텍스처 변경 가능 여부

        protected MaterialEditor materialEditor { get; set; }

        protected MaterialProperty surfaceTypeProp { get; set; }
        protected MaterialProperty cullingProp { get; set; }
        protected MaterialProperty zwriteProp { get; set; }
        protected MaterialProperty alphaClipProp { get; set; }
        protected MaterialProperty alphaCutoffProp { get; set; }


        protected MaterialProperty mainTexProp { get; set; }
        protected MaterialProperty colorProp { get; set; }


        public virtual void FindProperties(MaterialProperty[] properties)
        {
            Material material = materialEditor?.target as Material;
            if (!material) return;

            surfaceTypeProp = FindProperty(Property.SurfaceType, properties, false);
            zwriteProp = FindProperty(Property.ZWriteControl, properties, false);
            alphaClipProp = FindProperty(Property.AlphaClip, properties, false);

            mainTexProp = FindProperty("_MainTex", properties, false);
            colorProp = FindProperty("_Color", properties, false);
            alphaCutoffProp = FindProperty("_Cutoff", properties, false);
        }


        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] properties)
        {
            if (!materialEditorIn) throw new ArgumentNullException("materialEditorIn");

            materialEditor = materialEditorIn;
            Material material = materialEditor.target as Material;

            FindProperties(properties);
            if (m_FirstTimeApply)
            {
                // MaterialGUI Open Event
                m_FirstTimeApply = false;
            }

            DrawGUI(material);
        }

        public override void ValidateMaterial(Material material)
        {
            if (!material) throw new ArgumentNullException("material");
            if(m_isChangeRenderQueue)
            {
                m_isChangeRenderQueue = false;
                return;
            }
            base.ValidateMaterial(material);
            MaterialChanged(material);
        }


        public void DrawGUI(Material material)
        {
            DoPopup(Styles.surfaceType, surfaceTypeProp, Styles.surfaceTypeNames);
            DoPopup(Styles.zwriteText, zwriteProp, Styles.zwriteNames);

            if ((alphaClipProp != null) && (alphaCutoffProp != null) && (alphaClipProp.floatValue == 1))
                materialEditor.ShaderProperty(alphaCutoffProp, Styles.alphaClipThresholdText, 1);

            bool isPerRendererData = _isPerRendererData;
            GUI.enabled = !isPerRendererData;
            materialEditor.TextureProperty(mainTexProp, Styles.mainTex.text, true);
            GUI.enabled = true;
            materialEditor.ColorProperty(colorProp, Styles.color.text);
            EditorGUILayout.Space(5);
            // materialEditor.TexturePropertySingleLine(Styles.mainTex, mainTexProp, colorProp); // 텍스처 + 색상 합친 GUI

            EditorGUI.BeginChangeCheck();
            materialEditor.RenderQueueField();

            if (EditorGUI.EndChangeCheck())
            {
                m_isChangeRenderQueue = true;
            }
        }

        public void MaterialChanged(Material material)
        {
            CoreUtils.SetKeyword(material, "_ALPHATEST_ON", false);
            if(alphaClipProp!=null) alphaClipProp.floatValue = 0.0f;

            int renderQueue = material.shader.renderQueue;
            material.SetOverrideTag("RenderType", "");      // clear override tag
            if (material.HasProperty(Property.SurfaceType))
            {
                SurfaceType surfaceType = (SurfaceType)material.GetFloat(Property.SurfaceType);
                bool zwrite = true;
           
                if (surfaceType == SurfaceType.Opaque)
                {
                    renderQueue = (int)RenderQueue.Geometry;
                    material.SetOverrideTag("RenderType", "Opaque");
                    SetMaterialSrcDstBlendProperties(material, BlendMode.One, BlendMode.Zero);
                    zwrite = true;
                }
                else if(surfaceType == SurfaceType.AlphaTest)
                {
                    CoreUtils.SetKeyword(material, "_ALPHATEST_ON", true);
                    if (alphaClipProp != null) alphaClipProp.floatValue = 1.0f;
                    renderQueue = (int)RenderQueue.AlphaTest;
                    material.SetOverrideTag("RenderType", "TransparentCutout");
                    SetMaterialSrcDstBlendProperties(material, BlendMode.One, BlendMode.Zero);
                    zwrite = true;
                }
                else if (surfaceType == SurfaceType.Transparent)
                {
                    renderQueue = (int)RenderQueue.Transparent;
                    material.SetOverrideTag("RenderType", "Transparent");
                    SetMaterialSrcDstBlendProperties(material, BlendMode.SrcAlpha,BlendMode.OneMinusSrcAlpha);  // Alpha Blend
                    // SetMaterialSrcDstBlendProperties(material, BlendMode.SrcAlpha, BlendMode.One);   // Additive
                    zwrite = false;
                }

                if (material.HasProperty(Property.ZWriteControl))
                {
                    var zwriteControl = (ZWriteControl)material.GetFloat(Property.ZWriteControl);
                    if (zwriteControl == ZWriteControl.ForceEnabled) zwrite = true;
                    else if (zwriteControl == ZWriteControl.ForceDisabled) zwrite = false;
                }
                SetMaterialZWriteProperty(material, zwrite);
                material.SetShaderPassEnabled("DepthOnly", zwrite);
            }
            else
            {
                CoreUtils.SetKeyword(material, "_ALPHATEST_ON", false);
                material.SetShaderPassEnabled("DepthOnly", true);
            }
            material.SetShaderPassEnabled("ShadowCaster", true);
            material.renderQueue = renderQueue;
        }


        public void DoPopup(GUIContent label, MaterialProperty property, string[] options)
        {
            if (property != null)
                materialEditor.PopupShaderProperty(property, label, options);
        }

        internal static void DrawFloatToggleProperty(GUIContent styles, MaterialProperty prop)
        {
            if (prop == null)
                return;

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;
            bool newValue = EditorGUILayout.Toggle(styles, prop.floatValue == 1);
            if (EditorGUI.EndChangeCheck())
                prop.floatValue = newValue ? 1.0f : 0.0f;
            EditorGUI.showMixedValue = false;
        }

        internal static void SetMaterialSrcDstBlendProperties(Material material, UnityEngine.Rendering.BlendMode srcBlend, UnityEngine.Rendering.BlendMode dstBlend)
        {
            if (material.HasProperty(Property.SrcBlend))
                material.SetFloat(Property.SrcBlend, (float)srcBlend);

            if (material.HasProperty(Property.DstBlend))
                material.SetFloat(Property.DstBlend, (float)dstBlend);
        }

        internal static void SetMaterialZWriteProperty(Material material, bool zwriteEnabled)
        {
            if (material.HasProperty(Property.ZWrite))
                material.SetFloat(Property.ZWrite, zwriteEnabled ? 1.0f : 0.0f);
        }
    }
}