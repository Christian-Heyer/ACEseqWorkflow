#!/bin/bash

set -o pipefail
set -u

# which files to download
REFERENCE_GENOME=true
dbSNP_FILE=true
MAPPABILITY_FILE=true
REPLICATION_TIMING_FILE=true
statFiles=true
IMPUTE_FILES=true

set -eE
trap 'echo "Download incomplete. Please restart script."' ERR

mkdir_cd() {
	mkdir -p "$1"
	cd "$1"
}

check_md5sum() {
	local FILES=$(find -type f | sort)
	local MD5SUM=$([ -n "$FILES" ] && cat $FILES | md5sum | cut -f1 -d' ')
	[ "$EXPECTED_MD5SUM" = "$MD5SUM" ]
}

mkdir_cd hg19_GRCh37_1000genomes

if [[ "$REFERENCE_GENOME" == "true" ]] 
then
	(
	EXPECTED_MD5SUM=12a0bed94078e2d9e8c00da793bbc84e
	check_md5sum && exit 0 || echo downloading reference genome....
	mkdir_cd sequence/1KGRef
	wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
	gunzip sequence/1KGRef/hs37d5.fa.gz
	check_md5sum
	)
fi

if [[ "$dbSNP_FILE" == "true" ]]
then
	(
	EXPECTED_MD5SUM=fed2a31b5a5d8fe12e072576c0c17199
	check_md5sum && exit 0 || echo downloading dbSNP file....
	mkdir_cd databases/dbSNP/dbSNP_135

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
	bgzip > 00-All.SNV.vcf.gz
	tabix -p vcf 00-All.SNV.vcf.gz

	# CLEANUP
	rm -f 00-All.vcf.gz 00-All.vcf.gz.tbi
	check_md5sum
	)
fi

if [[ "$MAPPABILITY_FILE" == "true" ]]
then
	(
	EXPECTED_MD5SUM=3d12d0a4d7afdb52cfd10f886d48b5f0
	check_md5sum && exit 0 || echo downloading mappability file....
	mkdir_cd databases/UCSC
	wget -c http://hgdownload.soe.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeMapability/wgEncodeCrgMapabilityAlign100mer.bigWig
	bigWigToBedGraph wgEncodeCrgMapabilityAlign100mer.bigWig wgEncodeCrgMapabilityAlign100mer_chr.bedGraph
	rm -f wgEncodeCrgMapabilityAlign100mer.bigWig
	bgzip wgEncodeCrgMapabilityAlign100mer_chr.bedGraph
	tabix -p bed wgEncodeCrgMapabilityAlign100mer_chr.bedGraph.gz
	check_md5sum
	)
fi

if [[ "$REPLICATION_TIMING_FILE" == "true" ]]
then
	(
	EXPECTED_MD5SUM=2a63b34a737383af2a3f7eb32801a5fa
	check_md5sum && exit 0 || echo downloading replication timing file....
	mkdir_cd databases/ENCODE
	wget -c https://raw.githubusercontent.com/eilslabs/ACEseqWorkflow/github/installation/ReplicationTime_10cellines_mean_10KB.Rda
	check_md5sum
	)
fi

if [[ "$statFiles" == "true" ]]
then
	(
	EXPECTED_MD5SUM=801bdaa8c3b0d5c18a0637b0b29fd337
	check_md5sum && exit 0 || echo downloading stats files....
	mkdir_cd stats

	wget -c http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/chromInfo.txt.gz
	zcat chromInfo.txt.gz | grep -Pv "(_)|(chrM)" | sed -e '1i\#chrom\tsize\tfileName' > chrlengths.txt
	rm -f chromInfo.txt.gz

	wget -c https://raw.githubusercontent.com/eilslabs/ACEseqWorkflow/github/installation/hg19_GRch37_100genomes_gc_content_10kb.txt
	check_md5sum
	)
fi

if [[ "$IMPUTE_FILES" == "true" ]]
then
	(
	EXPECTED_MD5SUM=261a28d6b6917340cd82ada2d7185e17
	check_md5sum && exit 0 || echo downloading impute files....
	mkdir_cd databases/1000genomes/IMPUTE
	wget -c https://mathgen.stats.ox.ac.uk/impute/ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz
	tar -xzvf ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz -C databases/1000genomes/IMPUTE
	rm -f ALL.integrated_phase1_SHAPEIT_16-06-14.nomono.tgz
	wget -c https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz
	tar -xzvf ALL_1000G_phase1integrated_v3_impute.tgz -C databases/1000genomes/IMPUTE
	rm -f ALL_1000G_phase1integrated_v3_impute.tgz
	check_md5sum
	)
fi

echo "All files downloaded successfully"
