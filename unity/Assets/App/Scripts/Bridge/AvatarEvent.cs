using System;

namespace FitGame.Bridge
{
    [Serializable]
    public class AvatarEvent
    {
        public string type;
        public string requestId;
        public bool success = true;
        public string payload = "{}";
        public string error;
    }
}
