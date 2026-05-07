using UnityEngine;

namespace FitGame.Bridge
{
    public class UnityBridge : MonoBehaviour
    {
        [SerializeField] private AvatarCommandRouter commandRouter;

        private void Start()
        {
            DispatchEvent("UNITY_READY", string.Empty, "{}");
        }

        // Called by native iOS / Android Unity as a Library wrapper.
        public void PostMessage(string json)
        {
            if (commandRouter == null)
            {
                DispatchEvent("UNITY_ERROR", string.Empty, "{}", "Missing command router");
                return;
            }

            commandRouter.Route(json, DispatchEvent);
        }

        public void DispatchEvent(
            string type,
            string requestId,
            string payload,
            string error = null
        )
        {
            var success = string.IsNullOrEmpty(error);
            var eventPayload = string.IsNullOrEmpty(payload) ? "{}" : payload;
            var json =
                "{"
                + $"\"type\":\"{Escape(type)}\","
                + $"\"requestId\":\"{Escape(requestId)}\","
                + $"\"payload\":{eventPayload},"
                + $"\"success\":{success.ToString().ToLowerInvariant()},"
                + $"\"error\":{FormatNullable(error)}"
                + "}";
            Debug.Log($"UNITY_EVENT:{json}");
        }

        private static string FormatNullable(string value)
        {
            return string.IsNullOrEmpty(value) ? "null" : $"\"{Escape(value)}\"";
        }

        private static string Escape(string value)
        {
            return string.IsNullOrEmpty(value)
                ? string.Empty
                : value.Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
}
