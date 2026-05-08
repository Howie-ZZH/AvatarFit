using System.Collections;
using UnityEngine;

namespace FitGame.Avatar
{
    public class AvatarGrowthController : MonoBehaviour
    {
        [SerializeField] private Light growthLight;

        public void Bind(Light light)
        {
            growthLight = light;
        }

        public void PlayWorkoutComplete()
        {
            if (growthLight != null)
            {
                StartCoroutine(Flash());
            }
        }

        private IEnumerator Flash()
        {
            var start = growthLight.intensity;
            for (var i = 0; i < 24; i++)
            {
                growthLight.intensity = start + Mathf.Sin(i / 24f * Mathf.PI) * 4f;
                yield return null;
            }
            growthLight.intensity = start;
        }
    }
}
