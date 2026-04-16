#!/bin/bash
#SBATCH --job-name=pg_dev
#SBATCH --output=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_%j.out
#SBATCH --error=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_%j.err
#SBATCH --time=02:30:00
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

set -e

module --force purge
module load StdEnv/2023
module load python/3.11
module load gcc
module load arrow/23.0.1
module load cuda

cd /scratch/matla/ml_projects/parameter-golf
source venv/bin/activate

# Évite le blocage Torch / NCCL / UCX / MPI observé sur le cluster
export NCCL_IB_DISABLE=1
export NCCL_DEBUG=INFO
export UCX_TLS=tcp,self,sm
export OMPI_MCA_btl=self,tcp
export OMPI_MCA_pml=ob1

export TRITON_CACHE_DIR=/scratch/matla/ml_projects/experiments/parameter_golf/triton_cache
mkdir -p "$TRITON_CACHE_DIR"

if [ -z "${CONFIG:-}" ]; then
    echo "ERROR: CONFIG is not set"
    exit 1
fi

if [ -f "$CONFIG" ]; then
    set -a
    source "$CONFIG"
    set +a
else
    echo "ERROR: CONFIG file not found: $CONFIG"
    exit 1
fi

if [ -z "${SCRIPT:-}" ]; then
    echo "ERROR: SCRIPT is not set"
    exit 1
fi

export MAX_WALLCLOCK_SECONDS=0
export PYTHONUNBUFFERED=1

echo "=== Python / Torch sanity check ==="
python - <<'PY'
import sys, torch
print("Python :", sys.version)
print("Torch  :", torch.__version__)
print("CUDA OK:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU count:", torch.cuda.device_count())
    print("GPU 0    :", torch.cuda.get_device_name(0))
PY

echo "=== Environment ==="
env | grep -E '^(RUN_ID|DATA_PATH|TOKENIZER_PATH|VOCAB_SIZE|COMPILE_MODEL|COMPILE_MUON|COMPRESSION|LZMA_PRESET|MAX_WALLCLOCK_SECONDS|PYTHONUNBUFFERED|NCCL_IB_DISABLE|NCCL_DEBUG|UCX_TLS|OMPI_MCA_btl|OMPI_MCA_pml)='

python "$SCRIPT"