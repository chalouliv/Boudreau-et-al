#!/bin/bash
# ------------------------------------------------------------
# Script Name: ancestry_inference_pre_filter.sh
# Description: Performs pre-analysis filtering for Ancestry Inference
# Author: Peyton McClelland 
# Email: peyton.mcclelland@mail.mcgill.ca
# Date: 2025-09-08
# Manuscript: Boudreau et al. (Extended carrier screening in the Acadian population)
# ------------------------------------------------------------

set -e 

WORK_DIR=""
STUDY_VCF=""

# Load required modules
module load StdEnv/2020 plink/1.9b_6.21-x86_64 bcftools

# Enter working directory
cd "$WORK_DIR" || { echo "WORK_DIR does not exist"; exit 1; }

# Run filtering 
if [ "${PRUNE}" == "no" ]; then
    plink --vcf ${VCF} --geno ${F_MISS} --maf ${MAF} --hwe ${HWE} --mind ${MIND} --const-fid --keep-allele-order --recode vcf --out output/${OUT}
else
    plink --vcf ${VCF} --indep-pairwise 50 5 0.5 --const-fid --keep-allele-order
    plink --extract plink.prune.in --vcf ${VCF} --geno ${F_MISS} --maf ${MAF} --hwe ${HWE} --mind ${MIND} -- --const-fid --keep-allele-order --recode vcf --out output/${OUT}
    rm plink.prune.in plink.prune.out plink.log plink.nosex
fi
exit 0