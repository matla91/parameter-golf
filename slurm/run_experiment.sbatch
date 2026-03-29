#!/bin/bash
#SBATCH --job-name=pg_dev
#SBATCH --output=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_%j.out
#SBATCH --error=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_%j.err
#SBATCH --time=02:30:00
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

module --force purge
module load StdEnv/2023
module load python/3.11
module load gcc
module load arrow/23.0.1
module load cuda

cd /scratch/matla/ml_projects/parameter-golf
source venv/bin/activate

export TRITON_CACHE_DIR=/scratch/matla/ml_projects/experiments/parameter_golf/triton_cache
mkdir -p "$TRITON_CACHE_DIR"

if [ -f "$CONFIG" ]; then
    set -a
    source "$CONFIG"
    set +a
else
    echo "ERROR: CONFIG file not found: $CONFIG"
    exit 1
fi

export MAX_WALLCLOCK_SECONDS=0
export PYTHONUNBUFFERED=1

env | grep -E '^(RUN_ID|DATA_PATH|TOKENIZER_PATH|VOCAB_SIZE|COMPILE_MODEL|COMPILE_MUON|COMPRESSION|LZMA_PRESET|MAX_WALLCLOCK_SECONDS|PYTHONUNBUFFERED)='

python "$SCRIPT"