### LiftOver Conversion Script

Slightly modified script from [Patrick Deelen][liftover.script] for conversion between genomic build (physical positions).

#### Usage:

    liftover_plink input output chain_file
    
where `input` is the plink data without extensions, `output` the desired base name for the output, and `chain_file` the chain file obtained from [here][liftover.files] (_e.g._ hg19ToHg38.over.chain.gz).

#### Requirements:
- [LiftOver files,][liftover.files]
- [LiftOver Software][liftover.download],
- [Plink Software (version => 1.9)][plink]

[plink]: <https://www.cog-genomics.org/plink2>

[liftover.script]: <https://github.com/molgenis/Imputation/issues/4>
[liftover.files]: <http://hgdownload.cse.ucsc.edu/downloads.html>
[liftover.download]: <http://hgdownload.soe.ucsc.edu/admin/exe/>
