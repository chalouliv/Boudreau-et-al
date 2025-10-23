# Boudreau-et-al
This repository includes the source code required to process data and create the tables and figures featured in the Boudreau et al. paper on the extended carrier screening within the Acadian population residing in Atlantic Canada. 

## Contents
1. [ancestry_inference_pre_filter.sh](ancestry_inference_pre_filter.sh) and [admixture_pre_filter.sh](admixture_pre_filter.sh) - contain source code used for the pre-analysis filtering steps of Ancestry Inference and ADMIXTURE, respectively, in the *"Projection of sequencing results onto latent subspace from reference populations confirms French-European population ancestry"* section of the manuscript.

2. [run_admixture.sh](run_admixture.sh) and [run_admixture.cfg](run_admixture.cfg) - contain source code used for ADMIXTURE analysis in the *"Projection of sequencing results onto latent subspace from reference populations confirms French-European population ancestry"* section of the manuscript.

3. [HGDP_analysis-cp-NBseq_20250704.ipynb](HGDP_analysis-cp-NBseq_20250704.ipynb) - contains code for the plotting and visualization of the outputs of the Ancestry Inference preformed via Random Forest Model ([https://github.com/CERC-Genomic-Medicine/HGDP_1KG_ancestry_inference.git](https://github.com/CERC-Genomic-Medicine/HGDP_1KG_ancestry_inference.git)). 

4. [plot_admixture.R](plot_admixture.R) - contains R code for the plotting of the outputs of the ADMIXTURE analysis in the *"Projection of sequencing results onto latent subspace from reference populations confirms French-European population ancestry"* section and shown in *"Figure S4"* of the manuscript. 