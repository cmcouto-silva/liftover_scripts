#!/bin/bash

# Check input arguments
if [ "$#" -ne 3 ]; then
	echo "Usage:"
	echo " - Arg 1: input plink data (without extentions)"
	echo " - Arg 2: output (without extentions)"
	echo " - Arg 3: chain file"
	echo ""
	exit 1
fi

tmp="liftOver_temporary_files"

if [ -d "$tmp" ]; then
        echo 'Temporary folder "tmp" exists. Please remove or rename it before running this script.'
        exit 1
fi

input=$1
output=$2
chain=$3

mkdir $tmp
echo "Input: ${input}"
echo "Output: ${output}"
echo "Chain: ${chain}"

# Set temporarily files
input_bed="${tmp}/input.bed"
output_bed="${tmp}/output.bed"
unmapped="${tmp}/unmapped.txt"
mappingUpdate="${tmp}/mappingUpdate.txt"
unSorted="${tmp}/unSorted"

# Create bed
awk '{print "chr"$1,$4,$4+1,$2}' OFS="\t" "${input}.bim" > $input_bed

# Get updated mappings
liftOver -bedPlus=4 $input_bed $chain $output_bed $unmapped

# Parse unmapped SNPs
awk '/^[^#]/ {print $4}' $unmapped > ${unmapped}.tmp && mv ${unmapped}.tmp $unmapped

# Create mapping update list used by Plink
awk '{print $4, $2}' OFS="\t" $output_bed > $mappingUpdate

# Update plink mappings
plink2 \
	--bfile $input \
	--exclude $unmapped \
	--update-map $mappingUpdate \
	--sort-vars \
	--make-pgen \
	--out $unSorted

# Sort base pairs to binary ped
plink2 \
	--pfile $unSorted \
	--make-bed \
	--out $output

# Remove temporary files
rm -r $tmp

