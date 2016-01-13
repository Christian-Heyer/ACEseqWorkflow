#!/bin/bash

set -o pipefail
source ${CONFIG_FILE}
set -x

tmpClusteredSeg=${FILENAME_CLUSTERED_SEGMENTS}_tmp
tmpSnpsOut=${FILENAME_ALL_SNP_UPDATE2}_tmp


${RSCRIPT_BINARY} --vanilla 		  "${TOOL_MANUAL_PRUNING_SEGMENTS}" \
            	  --file              "${FILENAME_ALL_SNP_UPDATE1}" \
            	  --segments          "${FILENAME_SEGMENTS_W_HOMDEL}" \
	              --functions		  "${TOOL_CLUSTER_FUNCTIONS}" \
            	  --out               "${aceseqOutputDirectory}" \
	              --segOut		      "${tmpClusteredSeg}" \
            	  --min_seg_length    ${min_seg_length_prune} \
            	  --clustering_YN     $clustering \
            	  --min_num_cluster   $min_cluster_number \
	              --min_num_SNPs	  $min_num_SNPs \
            	  --min_membership    $min_membership \
            	  --min_distance      $min_distance \
    	    	  --blockPre		  ${haplogroupFilePath}	\
	              --blockSuf		  ${haplogroupFileSuffix}	\
	              --adjustAlleles	  ${TOOL_ADJUST_ALLELE_ASSIGNMENT} \
	              --newFile		      ${tmpSnpsOut} \
	              --sex		          ${FILENAME_SEX} \
	              --gcCovWidthFile    ${FILENAME_GC_CORRECTED_QUALITY} \
	              --chrLengthFile     ${CHROMOSOME_LENGTH_FILE} \
	              --pid               ${pid} \
	              --libloc            "${libloc_flexclust}"

if [[ "$?" != 0 ]]
then
	echo "There was a non-zero exit code while pruning manually;" 
	exit 2
fi

mv ${tmpClusteredSeg} ${FILENAME_CLUSTERED_SEGMENTS}
mv ${tmpSnpsOut} ${FILENAME_ALL_SNP_UPDATE2}

$TABIX_BINARY -f -s 1 -b 3 -e 4 ${FILENAME_ALL_SNP_UPDATE2}

if [[ "$?" != 0 ]]
then
	echo "There was a non-zero exit code while pruning manually;" 
	exit 2
fi
