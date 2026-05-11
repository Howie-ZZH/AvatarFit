using FitGame.Config;
using UnityEngine;

namespace FitGame.Avatar
{
    public class AvatarAppearanceController : MonoBehaviour
    {
        [SerializeField] private Renderer[] renderers;
        [SerializeField] private OutfitMapConfig outfitMap;
        [SerializeField] private Transform outfitRoot;
        [SerializeField] private Renderer[] accentRenderers;

        public void Bind(Renderer[] avatarRenderers)
        {
            renderers = avatarRenderers;
        }

        public void BindOutfits(OutfitMapConfig targetOutfitMap, Transform targetOutfitRoot)
        {
            outfitMap = targetOutfitMap;
            outfitRoot = targetOutfitRoot;
        }

        public void BindAccentRenderers(Renderer[] targetAccentRenderers)
        {
            accentRenderers = targetAccentRenderers;
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
            ApplyColor(color, accentRenderers ?? renderers);
        }

        public void ChangeOutfit(string outfitId)
        {
            if (TryChangeMappedOutfit(outfitId))
            {
                return;
            }

            var color = outfitId switch
            {
                "outfit_starter_gloves" => new Color(1f, 0.78f, 0.25f),
                "outfit_training_red" => new Color(0.95f, 0.24f, 0.28f),
                _ => new Color(0.13f, 0.83f, 0.65f)
            };
            ApplyColor(color, accentRenderers ?? renderers);
        }

        private bool TryChangeMappedOutfit(string outfitId)
        {
            if (outfitMap == null || outfitRoot == null)
            {
                return false;
            }

            if (!outfitMap.TryGet(outfitId, out var entry))
            {
                Debug.LogWarning($"Outfit id is not mapped: {outfitId}");
                return false;
            }

            for (var i = outfitRoot.childCount - 1; i >= 0; i--)
            {
                Destroy(outfitRoot.GetChild(i).gameObject);
            }

            if (entry.outfitPrefab != null)
            {
                var outfit = Instantiate(entry.outfitPrefab, outfitRoot);
                outfit.name = entry.outfitPrefab.name;
                renderers = outfit.GetComponentsInChildren<Renderer>(true);
            }

            ApplyColor(entry.accentColor, accentRenderers ?? renderers);
            return true;
        }

        private void ApplyColor(Color color, Renderer[] targetRenderers)
        {
            if (targetRenderers == null)
            {
                return;
            }

            foreach (var avatarRenderer in targetRenderers)
            {
                if (avatarRenderer != null)
                {
                    avatarRenderer.material.color = color;
                }
            }
        }
    }
}
