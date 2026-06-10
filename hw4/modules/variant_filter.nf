process FILTER_VARIANTS {
    tag "${meta.id}"
    label 'process_medium'
    publishDir "${params.output_dir}/filtered_variants", mode: 'copy'

    input:
    tuple val(meta), path(vcf), path(tbi)

    output:
    tuple val(meta), path("*_filtered.vcf.gz"), path("*_filtered.vcf.gz.tbi")

    stub:
    """
    echo "[STUB] Would filter variants from ${vcf} for sample ${meta.id}"
    touch ${meta.id}_filtered.vcf.gz
    touch ${meta.id}_filtered.vcf.gz.tbi
    """

    script:
    def min_qual = task.ext.args_min_qual ?: '20'
    """
    bcftools filter \\
        -i 'QUAL >= ${min_qual}' \\
        -Oz \\
        -o ${meta.id}_filtered.vcf.gz \\
        ${vcf}

    bcftools index -t ${meta.id}_filtered.vcf.gz
    """
}