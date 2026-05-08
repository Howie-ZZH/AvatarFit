using UnityEngine;

namespace FitGame.Avatar
{
    public class AvatarCaptureController : MonoBehaviour
    {
        public string CaptureShareImage()
        {
            var path = System.IO.Path.Combine(
                Application.persistentDataPath,
                $"fitgame_share_{System.DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}.png"
            );
            ScreenCapture.CaptureScreenshot(path);
            return path;
        }
    }
}
