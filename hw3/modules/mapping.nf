process INDEX_REFERENCE {
    tag "${ref_name}"
    label 'process_low'

    input:
    tuple val(ref_name), path(reference)

    output:
    tuple val(ref_name), path(reference), path("${reference}.bwt"), path("${reference}.ann"), path("${reference}.amb"), path("${reference}.pac"), path("${reference}.sa")

    script:
    """
    bwa index ${reference}
    """
}

process MAP_READS {
    tag "${sample_id}"
    label 'process_high'

    input:
    tuple val(ref_name), path(reference), path(ref_bwt), path(ref_ann), path(ref_amb), path(ref_pac), path(ref_sa), val(sample_id), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample_id), path("${sample_id}_mapped_sorted.bam"), path("${sample_id}_mapped_sorted.bam.bai")

    script:
    """
    bwa mem -t ${task.cpus} ${reference} ${fastq_1} ${fastq_2} | \\
        samtools sort -@ ${task.cpus} -o ${sample_id}_mapped_sorted.bam -
    samtools index ${sample_id}_mapped_sorted.bam
    """
}
