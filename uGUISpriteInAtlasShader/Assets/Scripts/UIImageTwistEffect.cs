using UnityEngine;
using UnityEngine.UI;

namespace Effect
{
    [RequireComponent(typeof(VertIndexAsUV1))]
    public class UIImageTwistEffect : MonoBehaviour
    {
        public Shader shaderEffect;
        [Range(-1, 1)]
        public float distortion = 1.6f;
        [Range(-1, 2)]
        public float posX = 0.5f;
        [Range(-1, 2)]
        public float posY = 0.5f;
        public float showTime;
        public bool activeEffect;

        private Graphic m_Graphic;
        private Material m_MaterialTemp;
        private float m_ChangeValuePerSec;

        private void Awake()
        {
            m_Graphic = GetComponent<Graphic>();
            m_MaterialTemp = m_Graphic.material;
        }

        private void SetMaterial()
        {
            if (shaderEffect)
            {
                m_Graphic.material = new Material(shaderEffect);

                Image img = GetComponent<Image>();
                if (img)
                {
                    Vector4 uvRect = UnityEngine.Sprites.DataUtility.GetOuterUV(img.overrideSprite);
                    m_Graphic.material.SetVector("_UvRect", uvRect);
                }
            }
        }

        private void DestroyMaterial()
        {
            DestroyImmediate(m_Graphic.material);
            m_Graphic.material = m_MaterialTemp;
        }

        private void Update()
        {
            if (m_Graphic == null)
            {
                return;
            }

            if (!activeEffect)
            {
                return;
            }

            if (showTime <= 0)
            {
                activeEffect = false;
                DestroyMaterial();
                return;
            }

            showTime -= Time.deltaTime;
            distortion += m_ChangeValuePerSec * Time.deltaTime;
            distortion = Mathf.Min(distortion, 1);

            m_Graphic.material.SetFloat("_Distortion", distortion);
            m_Graphic.material.SetFloat("_PosX", posX);
            m_Graphic.material.SetFloat("_PosY", posY);
        }

        public void SetTwist(float time)
        {
            showTime = time;
            m_ChangeValuePerSec = 1.0f / showTime;
            activeEffect = true;
            distortion = -1;

            SetMaterial();
        }

        [ContextMenu("播放效果")]
        public void StartTwist()
        {
            SetTwist(0.6f);
        }
    }
}

