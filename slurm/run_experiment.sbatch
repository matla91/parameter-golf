#!/usr/bin/env bash
#SBATCH --job-name=pg
#SBATCH --output=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_logs/%x_%j.out
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=02:30:00

set -euo pipefail

REPO_DIR="/scratch/matla/ml_projects/parameter-golf"
EXP_DIR="/scratch/matla/ml_projects/experiments/parameter_golf"

cd "$REPO_DIR"

if [ -f .venv/bin/activate ]; then
    source .venv/bin/activate
fi

source "$CONFIG"

STAMP=$(date +%Y%m%d_%H%M%S)
GIT_SHA=$(git rev-parse --short HEAD)
RUN_ID="${RUN_ID}_${STAMP}_${GIT_SHA}"
OUT_DIR="$EXP_DIR/runs/$RUN_ID"

mkdir -p "$OUT_DIR"
mkdir -p "$EXP_DIR/slurm_logs"

cp "$CONFIG" "$OUT_DIR/config.env"
cp "$SCRIPT" "$OUT_DIR/$(basename "$SCRIPT")"
git rev-parse HEAD > "$OUT_DIR/git_commit.txt"
printf '%s\n' "CONFIG=$CONFIG" "SCRIPT=$SCRIPT" "RUN_ID=$RUN_ID" > "$OUT_DIR/run_info.txt"

export RUN_ID
export OUT_DIR
export NCCL_IB_DISABLE=1
export NCCL_P2P_DISABLE=1
export PYTHONUNBUFFERED=1

echo "RUN_ID=$RUN_ID"
echo "OUT_DIR=$OUT_DIR"
echo "SCRIPT=$SCRIPT"
echo "CONFIG=$CONFIG"

python -u "$SCRIPT" > "$OUT_DIR/console.log" 2>&1