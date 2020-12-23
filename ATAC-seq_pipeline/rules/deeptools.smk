rule bamCoverage:
    input:
        map_sorted = WORKING_DIR + "sort/{samples}.sorted.bam"
    output:
        coverage_track = RESULT_DIR + "bamCoverage/{samples}.bw"
    params:
        effectiveGenomeSize     = str(config['bamCoverage']['effectiveGenomeSize']),
        normalization           = str(config['bamCoverage']['normalization']),
        binSize                 = str(config['bamCoverage']['binSize'])
    log:
        RESULT_DIR + "logs/bamCoverage/{samples}.bw.log"
    conda:
        "../envs/deeptools.yaml"
    shell:
        "bamCoverage -b {input} --effectiveGenomeSize {params.effectiveGenomeSize} --normalizeUsing {params.normalization} --ignoreDuplicates -o {output} --binSize {params.binSize}"
#bdg: create bedgraph output files
#format=BAMPE: only use properly-paired read alignments


# rule multibigwigSummary need to be expanded to use more than 1 bigwig file
# Right now the file only use 1 file, which is not useful for a comparison
rule multibigwigSummary:
    input:
        lambda wildcards: expand(RESULT_DIR + "bamCoverage/{sample}.bw", sample = SAMPLES)
    output:
        bigwigsummary = RESULT_DIR + "bigwigsummary/multiBigwigSummary.npz"
    log:
        RESULT_DIR + "logs/bigwigsummary/multiBigwigSummary.log"
    conda:
        "../envs/deeptools.yaml"
    shell:
        "multiBigwigSummary bins -b {input} -o {output} "
#2>{log}
# PlotPCA does not work with a bigwigsummary made of only one sample
rule PCA:
    input:
        bigwigsummary = RESULT_DIR + "bigwigsummary/multiBigwigSummary.npz"
    output:
        PCAplot = RESULT_DIR + "PCA/PCA_PLOT.pdf"
    log:
        RESULT_DIR + "logs/bigwigsummary/PCA_PLOT.log"
    conda:
        "../envs/deeptools.yaml"
    shell:
        "plotPCA -in {input} -o {output} 2>{log}"