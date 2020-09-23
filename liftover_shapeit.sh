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
sample="${tmp}/orig.sample"

# Copy the original .sample file
cp "${input}.sample" "${sample}"

# Create bed
awk '{print "chr"$1,$3,$3+1,$2}' OFS="\t" "${input}.haps" > $input_bed

# Get updated mappings
liftOver -bedPlus=4 $input_bed $chain $output_bed $unmapped

# Parse unmapped SNPs
awk '/^[^#]/ {print $4}' $unmapped > ${unmapped}.tmp && mv ${unmapped}.tmp $unmapped

# Create mapping update list used by Plink
awk '{print $4, $2}' OFS="\t" $output_bed > $mappingUpdate

# Update plink mappings
plink2 \
	--haps $input.haps \
	--sample $input.sample \
	--missing-code -9 \
	--exclude $unmapped \
	--update-map $mappingUpdate \
	--export haps \
	--out $unSorted

# Sort position per chromosome
plink2 \
	--haps $unSorted.haps \
	--sample $unSorted.sample \
	--export haps \
	--out $output

# Restore the original .sample file
cp "${sample}" "${output}.sample"

# Remove temporary files
rm -r $tmp
