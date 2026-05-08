using FitGame.Data;
using UnityEngine;

namespace FitGame.Avatar
{
    public class AvatarController : MonoBehaviour
    {
        [SerializeField] private AvatarAnimationController animationController;
        [SerializeField] private AvatarAppearanceController appearanceController;
        [SerializeField] private AvatarGrowthController growthController;
        [SerializeField] private AvatarCaptureController captureController;
        [SerializeField] private TextMesh label;

        public void Bind(
            AvatarAnimationController animation,
            AvatarAppearanceController appearance,
            AvatarGrowthController growth,
            AvatarCaptureController capture,
            TextMesh nameLabel
        )
        {
            animationController = animation;
            appearanceController = appearance;
            growthController = growth;
            captureController = capture;
            label = nameLabel;
        }

        public void SetAvatarState(AvatarStateData state)
        {
            if (label != null)
            {
                label.text = $"Lv.{state.level} {state.name}";
            }
            appearanceController.SetEnergyState(state.energyState);
            animationController.Play(state.energyState == "confident" ? "idle_confident" : "idle_default");
        }

        public void PlayAnimation(string animationKey)
        {
            animationController.Play(animationKey);
        }

        public void StartExercise(StartExerciseData exercise)
        {
            animationController.Play(exercise.animationKey);
        }

        public void WorkoutComplete(WorkoutCompleteData complete)
        {
            animationController.Play("result_level_up");
            growthController.PlayWorkoutComplete();
        }

        public void ChangeOutfit(ChangeOutfitData outfit)
        {
            appearanceController.ChangeOutfit(outfit.outfitId);
        }

        public string CaptureShareImage()
        {
            return captureController.CaptureShareImage();
        }
    }
}
