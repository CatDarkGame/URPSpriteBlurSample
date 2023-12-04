using UnityEngine;
using UnityEngine.U2D;
using UnityEngine.Rendering;
using Unity.Collections;
#if UNITY_EDITOR
using UnityEditor;
#endif


namespace CatDarkGame
{
    //[ExecuteInEditMode]
    [RequireComponent(typeof(SpriteRenderer))]
    [DisallowMultipleComponent]
    public class SpriteBlurRenderer : MonoBehaviour
    {
        [SerializeField][HideInInspector] private Material _materialAsset = null;
        [SerializeField][HideInInspector] private SpriteRenderer _spriteRenderer;
        private Sprite _sprite;
        
        [Range(0.01f, 16)][SerializeField] private float _blurPower = 2.0f;
        [Range(0, 1)][SerializeField] private float _BlendAmount = 0.5f;
        [SerializeField] private bool _customVertexStream = false;

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
            if (!_spriteRenderer) _spriteRenderer = GetComponent<SpriteRenderer>();
            _spriteRenderer.material = _materialAsset;


            // Sprite 에셋을 새로 생성하는 방식, (메모리 증가 위험)
            // Unity Sprite 시스템은 Sprite 에셋 = Mesh 역할.
            // 결론 : 이 방식도 올바른 솔루션이 아님
            if (_spriteRenderer && !_sprite)
            {
                _sprite = Instantiate(_spriteRenderer.sprite);
                _sprite.hideFlags = HideFlags.HideAndDontSave;
                _sprite.name = _sprite.name.Replace("(Clone)", "");
                _spriteRenderer.sprite = _sprite;
            }

        }

        private bool CheckCanUpdate()
        {
            if (!_spriteRenderer) return false;
            return true;
        }

        private void Update()
        {
            if (!CheckCanUpdate()) return;
            
            if (!_customVertexStream)
            {
                _materialAsset.DisableKeyword("_CUSTOMVERTEXSTREAM");
                MaterialPropertyBlock mpb = new MaterialPropertyBlock();
                _spriteRenderer.GetPropertyBlock(mpb);
                mpb.SetFloat("_BlurPower", _blurPower);
                mpb.SetFloat("_BlendAmount", _BlendAmount);
                _spriteRenderer.SetPropertyBlock(mpb);
            }
            else
            {
                _materialAsset.EnableKeyword("_CUSTOMVERTEXSTREAM");
                ModifyVertexAttribute(_spriteRenderer);
            }
        }

        void ModifyVertexAttribute(SpriteRenderer spriteRenderer)
        {
            Sprite sprite = spriteRenderer.sprite;
            if(sprite == null) return;
            
            int vertexCount = sprite.GetVertexCount();
            NativeArray<Vector2> texcoords2 = new NativeArray<Vector2>(vertexCount, Allocator.Temp);

            for (int i = 0; i < vertexCount; i++)
            {
                texcoords2[i] = new Vector2(_blurPower, _BlendAmount);
            }

            sprite.SetVertexAttribute(VertexAttribute.TexCoord1, texcoords2);
            texcoords2.Dispose();

            spriteRenderer.sprite = sprite;
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