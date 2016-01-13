#!/bin/bash

set -o pipefail
source ${CONFIG_FILE}
set -x

tmpSegments=${FILENAME_SEGMENTS}_tmp

${RSCRIPT_BINARY} --vanilla "${TOOL_PSCBS_SEGMENTATION}" \
	--file_data        "${FILE_PSCBS_DATA}" \
	--file_breakpoints "${FILENAME_BREAKPOINTS}" \
	--chrLengthFile "${CHROMOSOME_LENGTH_FILE}" \
	--file_fit         "${tmpSegments}" \
	--minwidth         $min_seg_width \
	--undo.SD          $undo_SD \
	-h                 $pscbs_prune_height \
	--crest            $CREST \
	--libloc           "${libloc_PSCBS}"

if [[ "$?" != 0 ]]
then
	echo "There was a non-zero exit code while generating fit.txt file;" 
	exit 2
fi

mv ${tmpSegments} ${FILENAME_SEGMENTS}