using UnityEngine;

namespace FitGame.Avatar
{
    public class AvatarAppearanceController : MonoBehaviour
    {
        [SerializeField] private Renderer[] renderers;

        public void Bind(Renderer[] avatarRenderers)
        {
            renderers = avatarRenderers;
        }

        public void SetEnergyState(string energyState)
        {
            var color = energyState switch
            {
                "tired" => new Color(0.35f, 0.45f, 0.55f),
                "confident" => new Color(1f, 0.78f, 0.25f),
                "peak" => new Color(0.28f, 0.85f, 1f),
                _ => new Color(0.13f, 0.83f, 0.65f)
            };
            ApplyColor(color);
        }

        public void ChangeOutfit(string outfitId)
        {
            var color = outfitId switch
            {
                "outfit_starter_gloves" => new Color(1f, 0.78f, 0.25f),
                "outfit_training_red" => new Color(0.95f, 0.24f, 0.28f),
                _ => new Color(0.13f, 0.83f, 0.65f)
            };
            ApplyColor(color);
        }

        private void ApplyColor(Color color)
        {
            if (renderers == null)
            {
                return;
            }

            foreach (var avatarRenderer in renderers)
            {
                avatarRenderer.material.color = color;
            }
        }
    }
}
