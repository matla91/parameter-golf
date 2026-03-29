param(
    [Parameter(Mandatory=$true)]
    [string]$Config,

    [string]$Script = "train_gpt_dev.py"
)

Write-Host "On the cluster, run:"
Write-Host "sbatch --export=ALL,CONFIG=$Config,SCRIPT=$Script slurm/run_experiment.sbatch"
