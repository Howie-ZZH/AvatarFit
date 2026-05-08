using UnityEngine;

namespace FitGame.Utils
{
    public static class JsonUtil
    {
        public static T FromJson<T>(string json) where T : new()
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return new T();
            }

            return JsonUtility.FromJson<T>(json);
        }
    }
}
