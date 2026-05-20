process BCFTOOLS_MPILEUP {
    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(bam), path(bai)
    tuple val(meta2), path(fasta)

    output:
    tuple val(meta), path("*.mpileup.vcf.gz")

    script:
    def args = task.ext.args ?: '-d 8000'
    """
    bcftools mpileup \\
        --fasta-ref ${fasta} \\
        ${args} \\
        ${bam} | \\
    bcftools view \\
        -Oz -o ${meta.id}.mpileup.vcf.gz

    bcftools index ${meta.id}.mpileup.vcf.gz
    """
}

process BCFTOOLS_CALL {
    tag "${meta.id}"
    label 'process_medium'

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*variants.vcf.gz"), path("*variants.vcf.gz.tbi")

    script:
    def args = task.ext.args ?: '-mv'
    """
    bcftools call \\
        ${args} \\
        -Oz \\
        -o ${meta.id}_variants.vcf.gz \\
        ${vcf}

    bcftools index -t ${meta.id}_variants.vcf.gz
    """
}
