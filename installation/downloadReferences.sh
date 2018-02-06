#!/bin/bash

# which files to download
REFERENCE_GENOME=true
dbSNP_FILE=true
MAPPABILITY_FILE=true
CHROMOSOME_LENGTH_FILE=true
statFiles=true
IMPUTE_FILES=true

mkdir -p hg19_GRCh37_1000genomes &&
cd hg19_GRCh37_1000genomes

if [[ "$REFERENCE_GENOME" == "true" ]] 
then
	echo downloading reference genome....
	mkdir -p sequence/1KGRef
	wget -P sequence/1KGRef ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
	gunzip sequence/1KGRef/hs37d5.fa.gz
fi

if [[ "$dbSNP_FILE" == "true" ]]
then
	echo downloading dbSNP file....
	mkdir -p databases/dbSNP/dbSNP_135
	cd databases/dbSNP/dbSNP_135

	# CITATION
	#As a NCBI Resource: "Sherry ST, Ward MH, Kholodov M, Baker J, Phan L, Smigielski EM, Sirotkin K. dbSNP: the NCBI database of genetic variation. Nucleic Acids Res. 2001 Jan 1;29(1):308-11."
	#As a whole for a specific build (use this!) : "Database of Single Nucleotide Polymorphisms (dbSNP). Bethesda (MD): National Center for Biotechnology Information, National Library of Medicine. (dbSNP Build ID: 141 ). Available from: http://www.ncbi.nlm.nih.gov/SNP/"
	#A single or a range of Submitted SNP (ss) or Reference SNP (rs) entries: "Database of Single Nucleotide Polymorphisms (dbSNP). Bethesda (MD): National Center for Biotechnology Information, National Library of Medicine. dbSNP accession:{ss1 or ss1 – ss100}, (dbSNP Build ID: 141). Available from: http://www.ncbi.nlm.nih.gov/SNP/"

	# DOWNLOAD
        wget -c ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh37p13/VCF/README.txt
        wget -c ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh37p13/VCF/00-All.vcf.gz
        wget -c ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh37p13/VCF/00-All.vcf.gz.tbi

	# POST PROCESSING
	# extract SNPs from dbSNP version 135 and older
	zcat 00-All.vcf.gz |
	awk '/^#/{print} /VC=SNV/{ v=$8; sub(/.*dbSNPBuildID=/, "", v); sub(/;.*/, "", v); if (v~/^[0-9]+$/ && int(v)<=135) print }' |
	bgzip > 00-All.SNV.vcf.gz &&
	tabix -p vcf 00-All.SNV.vcf.gz

	# CLEANUP
	rm -f 00-All.vcf.gz 00-All.vcf.gz.tbi
fi

if [[ "$MAPPABILITY_FILE" == "true" ]]
then
	echo downloading mappability file....
	mkdir -p databases/UCSC
	wget -P databases/UCSC  http://hgdownload.soe.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeMapability/wgEncodeCrgMapabilityAlign100mer.bigWig
	echo "please convert the bigwig file to bedgraph"
fi

if [[ "$CHROMOSOME_LENGTH_FILE" == "true" ]] 
then
	echo downloading dbSNP file....
	mkdir -p stats
	wget -qO- http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/chromInfo.txt.gz  | zcat | grep -Pv "(_)|(chrM)" | sed -e '1i\#chrom\tsize\tfileName' >stats/chrlengths.txt
fi

if [[ "$statFiles" == "true" ]]
then
	echo downloading statsfile....
	mkdir -p stats
	wget -c -O stats/hg19_GRch37_100genomes_gc_content_10kb.txt https://github.com/eilslabs/ACEseqWorkflow/blob/github/installation/hg19_GRch37_100genomes_gc_content_10kb.txt?raw=true
	mkdir -p databases/ENCODE/
	wget -c -O databases/ENCODE/ReplicationTime_10cellines_mean_10KB.Rda https://github.com/eilslabs/ACEseqWorkflow/blob/github/installation/ReplicationTime_10cellines_mean_10KB.Rda?raw=true
fi

if [[ "$IMPUTE_FILES" == "true" ]]
then
	echo downloading impute files....
	mkdir -p databases/1000genomes/IMPUTE
	wget -P databases/1000genomes/IMPUTE https://mathgen.stats.ox.ac.uk/impute/ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz
	tar -xzvf databases/1000genomes/IMPUTE/ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz -C databases/1000genomes/IMPUTE
	rm -f databases/1000genomes/IMPUTE/ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz
	wget -P databases/1000genomes/IMPUTE https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz
	tar -xzvf databases/1000genomes/IMPUTE/ALL_1000G_phase1integrated_v3_impute.tgz -C databases/1000genomes/IMPUTE
	rm -f databases/1000genomes/IMPUTE/ALL_1000G_phase1integrated_v3_impute.tgz
fi

