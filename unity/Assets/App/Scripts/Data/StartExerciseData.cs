using System;

namespace FitGame.Data
{
    [Serializable]
    public class StartExerciseData
    {
        public string exerciseId;
        public string animationKey;
        public int durationSeconds;
        public int sets;
        public int reps;
    }
}
