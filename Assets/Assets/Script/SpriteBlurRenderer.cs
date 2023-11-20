using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif


namespace CatDarkGame
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Renderer))]
    [DisallowMultipleComponent]
    public class SpriteBlurRenderer : MonoBehaviour
    {
        [SerializeField][HideInInspector] private Material _materialAsset = null;

        private Renderer _spriteRenderer;
        [Range(0.01f, 16)][SerializeField] private float _blurPower = 2.0f;
        [Range(0, 1)][SerializeField] private float _BlendAmount = 0.5f;
        private void OnEnable()
        {
#if UNITY_EDITOR
            if (!_materialAsset)
            {
                string assetPath = GetScriptAssetPath + "/Material/CatDarkGame_Sprites_Sprite_Blur.mat";
                Debug.Log(assetPath);
                _materialAsset = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
            }
#endif
            if (!_spriteRenderer) _spriteRenderer = GetComponent<Renderer>();
            _spriteRenderer.material = _materialAsset;

        }

        private bool CheckCanUpdate()
        {
            if (!_spriteRenderer) return false;
            return true;
        }

        private void Update()
        {
            if (!CheckCanUpdate()) return;

            MaterialPropertyBlock mpb = new MaterialPropertyBlock();
            _spriteRenderer.GetPropertyBlock(mpb);
           
            mpb.SetFloat("_BlurPower", _blurPower);
            mpb.SetFloat("_BlendAmount", _BlendAmount);

            _spriteRenderer.SetPropertyBlock(mpb);

        }


#if UNITY_EDITOR
        private string GetScriptAssetPath
        {
            get
            {
                string path = AssetDatabase.FindAssets($"t:Script {nameof(SpriteBlurRenderer)}")[0];
                path = AssetDatabase.GUIDToAssetPath(path);
                return path.Substring(0, path.LastIndexOf("/"));
            }
        }
#endif
    }
}