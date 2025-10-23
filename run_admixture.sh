#!/bin/bash
#SBATCH --account=rrg-vmooser
#SBATCH --job-name=admixture
#SBATCH --time=24:00:00         
#SBATCH --cpus-per-task=4         
#SBATCH --mem=32G                
#SBATCH --array=1-10           
#SBATCH --output=log/%x_%A_%a.out    
#SBATCH --error=log/%x_%A_%a.err      

# Load config 
source admixture.cfg

# Load required modules
module load StdEnv/2020 admixture  plink/1.9b_6.21-x86_64

# Get current K value from array index
INDEX=${SLURM_ARRAY_TASK_ID}

# Enter working directory
cd "$WORK_DIR" || { echo "WORK_DIR does not exist"; exit 1; }

# Create sub directories
mkdir -p input  
mkdir -p log
mkdir -p output/admixture 

if [ ! -e input/input.bed ]; then
    echo "Creating input files..."
    ./admixture_pre_filter.sh
fi

cd output/admixture 
echo "Starting ADMIXTURE for K=$INDEX"
echo "Job ID: $SLURM_JOB_ID Array ID: $SLURM_ARRAY_TASK_ID"

# Run Admixture (thread = 4 for SPEED vroom vroom)
admixture --cv ../../input/input.bed ${INDEX} -j4 2>&1 | tee log${INDEX}.out 