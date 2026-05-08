using System;

namespace FitGame.Data
{
    [Serializable]
    public class PlayAnimationData
    {
        public string animationKey;
        public bool loop = true;
        public float transitionSeconds = 0.2f;
    }
}
