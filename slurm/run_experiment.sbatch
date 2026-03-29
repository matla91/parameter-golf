#!/bin/bash
#SBATCH --job-name=pg_dev
#SBATCH --output=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_%j.out
#SBATCH --error=/scratch/matla/ml_projects/experiments/parameter_golf/slurm_%j.err
#SBATCH --time=02:30:00
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

# 1. Nettoyage et chargement des modules (CRITIQUE)
module --force purge
module load StdEnv/2023
module load python/3.11
module load gcc
module load arrow/23.0.1
module load cuda

# 2. Setup Environnement
cd /scratch/matla/ml_projects/parameter-golf
source venv/bin/activate

# 3. Chemins et Config
export TRITON_CACHE_DIR=/scratch/matla/ml_projects/experiments/parameter_golf/triton_cache
mkdir -p "$TRITON_CACHE_DIR"

# On charge la config .env passée par --export
if [ -f "$CONFIG" ]; then
    source "$CONFIG"
fi

# Variables de sécurité
export MAX_WALLCLOCK_SECONDS=0
export PYTHONUNBUFFERED=1

# 4. Lancement (On remet torchrun qui est plus propre pour l'init GPU)
torchrun --standalone --nproc_per_node=1 "$SCRIPT"