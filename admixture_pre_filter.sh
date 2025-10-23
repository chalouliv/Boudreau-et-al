#!/bin/bash
# ------------------------------------------------------------
# Script Name: admixture_pre_filter.sh
# Description: Performs pre-analysis filtering for ADMIXTURE
# Author: Charlotte Livingston
# Email: charlotte.livingston@mail.mcgill.ca
# Date: 2025-09-01
# Manuscript: Boudreau et al. (Extended carrier screening in the Acadian population)
# ------------------------------------------------------------

set -e 

source run_admixture.cfg 

# Load required modules
module load StdEnv/2020 plink/1.9b_6.21-x86_64 bcftools

# Enter working directory
cd "${WORK_DIR}" || { echo "WORK_DIR does not exist"; exit 1; }

# Find intersect of study and reference 
echo "Running intersection..."
bcftools isec -n=2 -p temp ${REF_VCF} ${STUDY_VCF}
bcftools merge -m none -Oz -o input/merged.vcf.gz temp/0000.vcf temp/0001.vcf
bcftools index -t -f input/merged.vcf.gz 


# Run filtering 
echo "Filtering variants..."
plink --vcf input/merged.vcf.gz --indep-pairwise 50 5 0.9 --const-fid --keep-allele-order
plink --extract plink.prune.in --vcf input/merged.vcf.gz --mind 0.05 --const-fid --keep-allele-order --recode vcf --out input/filtered.vcf
rm plink.prune.in plink.prune.out plink.log plink.nosex 
rm -r temp

# Make bed 
echo "Generating bed files..."
plink --vcf input/filtered.vcf --make-bed --keep-allele-order --const-fid --out input/input || { echo "Failed to make-bed from INPUT"; exit 3; }

exit 0