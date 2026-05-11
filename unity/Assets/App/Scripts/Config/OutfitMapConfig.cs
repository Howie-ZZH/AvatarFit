using System;
using UnityEngine;

namespace FitGame.Config
{
    [Serializable]
    public sealed class OutfitMapEntry
    {
        public string outfitId;
        public GameObject outfitPrefab;
        public Material[] overrideMaterials = Array.Empty<Material>();
        public Color accentColor = new Color(0.13f, 0.83f, 0.65f);
    }

    [CreateAssetMenu(
        fileName = "OutfitMapConfig",
        menuName = "FitGame/Outfit Map Config"
    )]
    public sealed class OutfitMapConfig : ScriptableObject
    {
        [SerializeField] private OutfitMapEntry[] entries = Array.Empty<OutfitMapEntry>();

        public bool TryGet(string outfitId, out OutfitMapEntry entry)
        {
            if (entries != null)
            {
                foreach (var candidate in entries)
                {
                    if (candidate != null && candidate.outfitId == outfitId)
                    {
                        entry = candidate;
                        return true;
                    }
                }
            }

            entry = null;
            return false;
        }
    }
}
