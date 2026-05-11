using System;
using UnityEngine;

namespace FitGame.Config
{
    [Serializable]
    public sealed class AnimationMapEntry
    {
        public string animationKey;
        public string stateName;
        public AnimationClip clip;
        public bool loop;
        public float transitionSeconds = 0.2f;
    }

    [CreateAssetMenu(
        fileName = "AnimationMapConfig",
        menuName = "FitGame/Animation Map Config"
    )]
    public sealed class AnimationMapConfig : ScriptableObject
    {
        [SerializeField] private AnimationMapEntry[] entries = Array.Empty<AnimationMapEntry>();

        public bool TryGet(string animationKey, out AnimationMapEntry entry)
        {
            if (entries != null)
            {
                foreach (var candidate in entries)
                {
                    if (candidate != null && candidate.animationKey == animationKey)
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
