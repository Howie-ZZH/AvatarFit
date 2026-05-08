using System;
using FitGame.Avatar;
using FitGame.Data;
using FitGame.Utils;
using UnityEngine;

namespace FitGame.Bridge
{
    public class AvatarCommandRouter : MonoBehaviour
    {
        [SerializeField] private AvatarController avatarController;

        public void Bind(AvatarController controller)
        {
            avatarController = controller;
        }

        public void Route(
            string json,
            Action<string, string, string, string> dispatchEvent
        )
        {
            if (string.IsNullOrEmpty(json))
            {
                dispatchEvent("UNITY_ERROR", string.Empty, "{}", "Empty command");
                return;
            }

            var command = new AvatarCommand
            {
                type = ExtractStringField(json, "type"),
                requestId = ExtractStringField(json, "requestId")
            };
            var hasTypeField = HasJsonField(json, "type");
            if (!IsSupportedCommand(command.type))
            {
                var inferredType = InferCommandType(json);
                if (!string.IsNullOrEmpty(inferredType))
                {
                    command.type = inferredType;
                }
            }

            var payload = ExtractPayload(json, command.type, hasTypeField);
            if (command == null || string.IsNullOrEmpty(command.type))
            {
                dispatchEvent("UNITY_ERROR", string.Empty, "{}", "Invalid command");
                return;
            }

            if (avatarController == null)
            {
                dispatchEvent(
                    "UNITY_ERROR",
                    command.requestId,
                    "{}",
                    "AvatarController is not bound"
                );
                return;
            }

            switch (command.type)
            {
                case "SET_AVATAR_STATE":
                    avatarController.SetAvatarState(JsonUtil.FromJson<AvatarStateData>(payload));
                    dispatchEvent("UNITY_READY", command.requestId, payload, null);
                    break;
                case "PLAY_ANIMATION":
                    avatarController.PlayAnimation(JsonUtil.FromJson<PlayAnimationData>(payload).animationKey);
                    dispatchEvent("ANIMATION_STARTED", command.requestId, payload, null);
                    break;
                case "START_EXERCISE":
                    avatarController.StartExercise(JsonUtil.FromJson<StartExerciseData>(payload));
                    dispatchEvent("ANIMATION_STARTED", command.requestId, payload, null);
                    break;
                case "WORKOUT_COMPLETE":
                    avatarController.WorkoutComplete(JsonUtil.FromJson<WorkoutCompleteData>(payload));
                    dispatchEvent("ANIMATION_FINISHED", command.requestId, payload, null);
                    break;
                case "CHANGE_OUTFIT":
                    avatarController.ChangeOutfit(JsonUtil.FromJson<ChangeOutfitData>(payload));
                    dispatchEvent("OUTFIT_CHANGED", command.requestId, payload, null);
                    break;
                case "CAPTURE_SHARE_IMAGE":
                    var path = avatarController.CaptureShareImage();
                    dispatchEvent(
                        "SHARE_IMAGE_CAPTURED",
                        command.requestId,
                        $"{{\"path\":\"{path.Replace("\\", "\\\\").Replace("\"", "\\\"")}\"}}",
                        null
                    );
                    break;
                default:
                    dispatchEvent(
                        "UNITY_ERROR",
                        command.requestId,
                        "{}",
                        $"Unsupported command: {command.type}"
                    );
                    break;
            }
        }

        private static string ExtractStringField(string json, string fieldName)
        {
            var start = FindRootFieldValueStart(json, fieldName);
            if (start < 0)
            {
                return string.Empty;
            }

            if (start >= json.Length || json[start] != '"')
            {
                return string.Empty;
            }

            var end = FindStringEnd(json, start);
            if (end <= start)
            {
                return string.Empty;
            }

            return UnescapeJsonString(json.Substring(start + 1, end - start - 2));
        }

        private static bool IsSupportedCommand(string type)
        {
            switch (type)
            {
                case "SET_AVATAR_STATE":
                case "PLAY_ANIMATION":
                case "START_EXERCISE":
                case "WORKOUT_COMPLETE":
                case "CHANGE_OUTFIT":
                case "CAPTURE_SHARE_IMAGE":
                    return true;
                default:
                    return false;
            }
        }

        private static string InferCommandType(string json)
        {
            if (
                HasJsonField(json, "xpGained")
                && HasJsonField(json, "levelBefore")
                && HasJsonField(json, "levelAfter")
            )
            {
                return "WORKOUT_COMPLETE";
            }

            if (
                HasJsonField(json, "avatarId")
                || HasJsonField(json, "xpToNextLevel")
                || HasJsonField(json, "energyState")
            )
            {
                return "SET_AVATAR_STATE";
            }

            return string.Empty;
        }

        private static bool HasJsonField(string json, string fieldName)
        {
            return FindRootFieldValueStart(json, fieldName) >= 0;
        }

        private static string ExtractPayload(string json, string commandType, bool hasTypeField)
        {
            var start = FindRootFieldValueStart(json, "payload");
            if (start < 0)
            {
                return IsSupportedCommand(commandType) && !hasTypeField
                    ? NormalizePayload(json)
                    : "{}";
            }

            var end = FindJsonValueEnd(json, start);
            if (end <= start)
            {
                return "{}";
            }

            var payload = json.Substring(start, end - start).Trim();
            return NormalizePayload(payload);
        }

        private static string NormalizePayload(string payload)
        {
            return string.IsNullOrEmpty(payload) || payload == "null" ? "{}" : payload.Trim();
        }

        private static int SkipWhitespace(string json, int index)
        {
            while (index < json.Length && char.IsWhiteSpace(json[index]))
            {
                index++;
            }

            return index;
        }

        private static int FindRootFieldValueStart(string json, string fieldName)
        {
            var index = SkipWhitespace(json, 0);
            if (index >= json.Length || json[index] != '{')
            {
                return -1;
            }

            var depth = 0;
            var inString = false;
            var escaped = false;
            for (; index < json.Length; index++)
            {
                var current = json[index];
                if (inString)
                {
                    if (escaped)
                    {
                        escaped = false;
                    }
                    else if (current == '\\')
                    {
                        escaped = true;
                    }
                    else if (current == '"')
                    {
                        inString = false;
                    }

                    continue;
                }

                if (current == '"')
                {
                    if (depth == 1)
                    {
                        var keyEnd = FindStringEnd(json, index);
                        if (keyEnd <= index)
                        {
                            return -1;
                        }

                        var key = UnescapeJsonString(json.Substring(index + 1, keyEnd - index - 2));
                        var colon = SkipWhitespace(json, keyEnd);
                        if (colon < json.Length && json[colon] == ':' && key == fieldName)
                        {
                            return SkipWhitespace(json, colon + 1);
                        }

                        index = keyEnd - 1;
                    }
                    else
                    {
                        inString = true;
                    }
                }
                else if (current == '{' || current == '[')
                {
                    depth++;
                }
                else if (current == '}' || current == ']')
                {
                    depth--;
                    if (depth <= 0)
                    {
                        break;
                    }
                }
            }

            return -1;
        }

        private static string UnescapeJsonString(string value)
        {
            return value
                .Replace("\\\"", "\"")
                .Replace("\\\\", "\\")
                .Replace("\\/", "/")
                .Replace("\\b", "\b")
                .Replace("\\f", "\f")
                .Replace("\\n", "\n")
                .Replace("\\r", "\r")
                .Replace("\\t", "\t");
        }

        private static int FindJsonValueEnd(string json, int start)
        {
            if (start >= json.Length)
            {
                return start;
            }

            var first = json[start];
            if (first == '{' || first == '[')
            {
                return FindContainerEnd(json, start);
            }

            if (first == '"')
            {
                return FindStringEnd(json, start);
            }

            var end = start;
            while (end < json.Length && json[end] != ',' && json[end] != '}')
            {
                end++;
            }

            return end;
        }

        private static int FindContainerEnd(string json, int start)
        {
            var depth = 0;
            var inString = false;
            var escaped = false;

            for (var index = start; index < json.Length; index++)
            {
                var current = json[index];
                if (inString)
                {
                    if (escaped)
                    {
                        escaped = false;
                    }
                    else if (current == '\\')
                    {
                        escaped = true;
                    }
                    else if (current == '"')
                    {
                        inString = false;
                    }

                    continue;
                }

                if (current == '"')
                {
                    inString = true;
                }
                else if (current == '{' || current == '[')
                {
                    depth++;
                }
                else if (current == '}' || current == ']')
                {
                    depth--;
                    if (depth == 0)
                    {
                        return index + 1;
                    }
                }
            }

            return start;
        }

        private static int FindStringEnd(string json, int start)
        {
            var escaped = false;
            for (var index = start + 1; index < json.Length; index++)
            {
                var current = json[index];
                if (escaped)
                {
                    escaped = false;
                }
                else if (current == '\\')
                {
                    escaped = true;
                }
                else if (current == '"')
                {
                    return index + 1;
                }
            }

            return start;
        }
    }
}
