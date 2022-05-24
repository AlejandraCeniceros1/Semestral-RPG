using System;
using StixGames.NatureCore;
using StixGames.NatureCore.Utility;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace StixGames.GrassShader
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(NatureMeshFilter))]
    [AddComponentMenu("Stix Games/General/Grass Renderer", 1)]
    public class GrassRenderer : MonoBehaviour
    {
        public Material Material;
        [LayerField] public int Layer;
        public ShadowCastingMode ShadowCastingMode = ShadowCastingMode.On;
        public bool ReceiveShadows = true;

        [Space] public bool AutoSetFloorColor = false;

        private NatureMeshFilter _natureMeshFilter;

        private MaterialPropertyBlock propertyBlock = null;

        public NatureMeshFilter NatureMeshFilter
        {
            get
            {
                return _natureMeshFilter != null
                    ? _natureMeshFilter
                    : (_natureMeshFilter = GetComponent<NatureMeshFilter>());
            }
        }

        private void Start()
        {
            if (AutoSetFloorColor)
            {
                UpdateFloorColor();
            }
        }

        private void OnEnable()
        {
#if UNITY_EDITOR
#if UNITY_2019_2_OR_NEWER
            SceneView.duringSceneGui -= EditorGrassTimeUpdate;
            SceneView.duringSceneGui += EditorGrassTimeUpdate;
#else
            SceneView.onSceneGUIDelegate -= EditorGrassTimeUpdate;
            SceneView.onSceneGUIDelegate += EditorGrassTimeUpdate;
#endif
#endif
        }

        private void OnDisable()
        {
#if UNITY_EDITOR
#if UNITY_2019_2_OR_NEWER
            SceneView.duringSceneGui -= EditorGrassTimeUpdate;
#else
            SceneView.onSceneGUIDelegate -= EditorGrassTimeUpdate;
#endif
#endif
        }

#if UNITY_EDITOR
        public void EditorGrassTimeUpdate(SceneView view)
        {
            UpdateGrassTime();
            SceneView.RepaintAll();
#if UNITY_2019_2_OR_NEWER
            EditorApplication.QueuePlayerLoopUpdate();
#endif
        }
#endif

        /// <summary>
        /// Set a material property block that will be used for rendering.
        /// </summary>
        /// <param name="propertyBlock"></param>
        public void SetPropertyBlock(MaterialPropertyBlock propertyBlock)
        {
            this.propertyBlock = propertyBlock;
        }

        private void LateUpdate()
        {
            if (Material == null)
            {
                return;
            }

            if (!GrassUtility.IsGrassMaterial(Material))
            {
                throw new InvalidOperationException("GrassMaterial does not use the DX11 Grass Shader");
            }

            if (Application.isEditor && !Application.isPlaying && AutoSetFloorColor)
            {
                UpdateFloorColor();
            }

            if (Material.shader.isSupported)
            {
                UpdateGrassTime();
                
                var meshes = NatureMeshFilter.GetMeshes();
                foreach (var mesh in meshes)
                {
                    //Update bounds with grass height
                    var original = mesh.bounds;
                    var modified = original;
                    modified.Expand(GrassUtility.GetMaxGrassHeight(Material));
                    mesh.bounds = modified;

                    //Draw mesh
                    Graphics.DrawMesh(mesh, transform.localToWorldMatrix, Material, Layer, null, 0, propertyBlock,
                        ShadowCastingMode, ReceiveShadows);

                    //Restore bounds
                    mesh.bounds = original;
                }
            }
        }

        private static void UpdateGrassTime()
        {
            // ReSharpers improvement isn't supported in Unity 5.6
            // ReSharper disable once Unity.PreferAddressByIdToGraphicsParams
            Shader.SetGlobalVector("_GrassTime",
                new Vector4(Time.time / 20, Time.time, Time.time * 2, Time.time * 3));
        }
        
        private void UpdateFloorColor()
        {
            var renderer = GetComponent<Renderer>();
            if (renderer != null)
            {
                var floorMaterial = renderer.sharedMaterial;

                var baseColor = floorMaterial.color;
                var colorTexture = floorMaterial.mainTexture;
                var offset = floorMaterial.mainTextureOffset;
                var scale = floorMaterial.mainTextureScale;

                GrassUtility.SetFloorColor(Material, baseColor);
                GrassUtility.SetFloorColorTexture(Material, colorTexture, offset, scale);
                return;
            }

            var terrain = GetComponent<Terrain>();
            if (terrain != null)
            {
                //TODO: Add terrain support for this

                Debug.LogWarning("Auto setting floor color isn't supported for terrain yet.");
            }
        }
    }
}