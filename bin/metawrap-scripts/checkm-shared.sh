#!/usr/bin/env bash

#SBATCH
#SBATCH --partition=shared
#SBATCH --job-name=CheckM
#SBATCH --time=72:0:0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G


comm () { ${PWD}/metawrap-scripts/print_comment.py "$1" "-"; }
error () { ${PWD}/metawrap-scripts/print_comment.py "$1" "*"; exit 1; }
warning () { ${PWD}/metawrap-scripts/print_comment.py "$1" "*"; }
announcement () { ${PWD}/metawrap-scripts/print_comment.py "$1" "#"; }

########################################################################################################
########################               LOADING IN THE PARAMETERS                ########################
########################################################################################################

echo "======================================="
echo "Running chekm ${@:1}"
echo "======================================="
echo ""

# config_file will be in the base directory
# config_file will be in the base directory
if [ ! -z "$CONFIG" ]; then
  source $CONFIG
  echo "Config file sourced: $CONFIG"
else
  source $DIR/config-metawrap
  echo "Config file sourced: $DIR/config-metawrap"
fi

if [[ $? -ne 0 ]]; then
	echo "cannot find config-metawrap file - something went wrong with the installation!"
	exit 1
fi

echo "Scripts sourced from: $SOFT"
echo "Modules sourced from: $PIPES"

# runs CheckM mini-pipeline on a single folder of bins
if [[ -d ${1}.checkm ]]; then rm -r ${1}.checkm; fi
comm "Running CheckM on $1 bins"
mkdir ${1}.tmp
checkm lineage_wf -x fa $1 ${1}.checkm -t 24 --tmpdir ${1}.tmp
if [[ ! -s ${1}.checkm/storage/bin_stats_ext.tsv ]]; then error "Something went wrong with running CheckM. Exiting..."; fi
rm -r ${1}.tmp

comm "Finalizing CheckM stats..."
${SOFT}/summarize_checkm.py ${1}.checkm/storage/bin_stats_ext.tsv > ${1}.stats

#comm "Making CheckM plot of $1 bins"
#checkm bin_qa_plot -x fa ${1}.checkm $1 ${1}.plot
#if [[ ! -s ${1}.plot/bin_qa_plot.png ]]; then warning "Something went wrong with making the CheckM plot. Exiting."; fi
#mv ${1}.plot/bin_qa_plot.png ${1}.png
#rm -r ${1}.plot


announcement "CheckM pipeline finished"
