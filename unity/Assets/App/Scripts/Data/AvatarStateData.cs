using System;

namespace FitGame.Data
{
    [Serializable]
    public class AvatarStateData
    {
        public string avatarId = "avatar_local_001";
        public string name = "Rex";
        public int level = 1;
        public int xp = 0;
        public int xpToNextLevel = 122;
        public string bodyType = "normal";
        public string energyState = "normal";
        public AvatarAttributesData attributes = new AvatarAttributesData();
        public AvatarEquipmentData equipment = new AvatarEquipmentData();
    }
}
