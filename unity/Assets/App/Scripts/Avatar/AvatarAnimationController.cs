using System.Collections;
using FitGame.Config;
using UnityEngine;

namespace FitGame.Avatar
{
    public class AvatarAnimationController : MonoBehaviour
    {
        [SerializeField] private Animator animator;
        [SerializeField] private AnimationMapConfig animationMap;
        [SerializeField] private Transform avatarRoot;
        [SerializeField] private Transform leftArm;
        [SerializeField] private Transform rightArm;
        [SerializeField] private Transform leftLeg;
        [SerializeField] private Transform rightLeg;

        private Coroutine currentRoutine;

        public void Bind(
            Transform root,
            Transform armLeft,
            Transform armRight,
            Transform legLeft,
            Transform legRight
        )
        {
            avatarRoot = root;
            leftArm = armLeft;
            rightArm = armRight;
            leftLeg = legLeft;
            rightLeg = legRight;
        }

        public void BindAnimator(Animator targetAnimator, AnimationMapConfig targetAnimationMap)
        {
            animator = targetAnimator;
            animationMap = targetAnimationMap;
        }

        public void Play(string animationKey)
        {
            if (TryPlayAnimatorState(animationKey))
            {
                return;
            }

            if (currentRoutine != null)
            {
                StopCoroutine(currentRoutine);
            }

            currentRoutine = StartCoroutine(Animate(animationKey));
        }

        private bool TryPlayAnimatorState(string animationKey)
        {
            if (animator == null || animationMap == null)
            {
                return false;
            }

            if (!animationMap.TryGet(animationKey, out var entry))
            {
                Debug.LogWarning($"Animation key is not mapped: {animationKey}");
                return false;
            }

            if (currentRoutine != null)
            {
                StopCoroutine(currentRoutine);
                currentRoutine = null;
            }

            var stateName = string.IsNullOrWhiteSpace(entry.stateName)
                ? animationKey
                : entry.stateName;
            animator.CrossFadeInFixedTime(stateName, Mathf.Max(0f, entry.transitionSeconds));
            return true;
        }

        private IEnumerator Animate(string animationKey)
        {
            var elapsed = 0f;
            while (true)
            {
                elapsed += Time.deltaTime;
                var wave = Mathf.Sin(elapsed * 6f);
                ApplyPose(animationKey, wave);
                yield return null;
            }
        }

        private void ApplyPose(string animationKey, float wave)
        {
            if (avatarRoot == null)
            {
                return;
            }

            avatarRoot.localPosition = new Vector3(0f, Mathf.Abs(wave) * 0.04f, 0f);
            ResetLimbs();

            switch (animationKey)
            {
                case "workout_squat":
                    avatarRoot.localScale = new Vector3(1f, 1f - Mathf.Abs(wave) * 0.18f, 1f);
                    SetLocalRotation(leftLeg, Quaternion.Euler(0f, 0f, 8f + wave * 8f));
                    SetLocalRotation(rightLeg, Quaternion.Euler(0f, 0f, -8f - wave * 8f));
                    break;
                case "workout_jumping_jack":
                    SetLocalRotation(leftArm, Quaternion.Euler(0f, 0f, 48f + wave * 30f));
                    SetLocalRotation(rightArm, Quaternion.Euler(0f, 0f, -48f - wave * 30f));
                    SetLocalRotation(leftLeg, Quaternion.Euler(0f, 0f, 12f + wave * 14f));
                    SetLocalRotation(rightLeg, Quaternion.Euler(0f, 0f, -12f - wave * 14f));
                    break;
                case "workout_plank":
                    avatarRoot.localRotation = Quaternion.Euler(70f, 0f, 0f);
                    avatarRoot.localPosition = new Vector3(0f, -0.55f + wave * 0.02f, 0f);
                    break;
                case "workout_stretch":
                    SetLocalRotation(leftArm, Quaternion.Euler(0f, 0f, 68f + wave * 10f));
                    SetLocalRotation(rightArm, Quaternion.Euler(0f, 0f, -24f));
                    break;
                case "result_level_up":
                case "result_success":
                    SetLocalRotation(leftArm, Quaternion.Euler(0f, 0f, 78f));
                    SetLocalRotation(rightArm, Quaternion.Euler(0f, 0f, -78f));
                    avatarRoot.localScale = Vector3.one * (1f + Mathf.Abs(wave) * 0.05f);
                    break;
                default:
                    avatarRoot.localScale = Vector3.one;
                    break;
            }
        }

        private void ResetLimbs()
        {
            avatarRoot.localRotation = Quaternion.identity;
            avatarRoot.localScale = Vector3.one;
            SetLocalRotation(leftArm, Quaternion.Euler(0f, 0f, 16f));
            SetLocalRotation(rightArm, Quaternion.Euler(0f, 0f, -16f));
            SetLocalRotation(leftLeg, Quaternion.Euler(0f, 0f, 4f));
            SetLocalRotation(rightLeg, Quaternion.Euler(0f, 0f, -4f));
        }

        private static void SetLocalRotation(Transform target, Quaternion rotation)
        {
            if (target != null)
            {
                target.localRotation = rotation;
            }
        }
    }
}
