using System;

namespace FitGame.Data
{
    [Serializable]
    public class WorkoutCompleteData
    {
        public int xpGained;
        public int levelBefore;
        public int levelAfter;
        public AvatarAttributesData attributeDelta = new AvatarAttributesData();
    }
}
