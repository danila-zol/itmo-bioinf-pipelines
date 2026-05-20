process TRIM_READS {
    tag "${sample_id}"
    label 'process_medium'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample_id), path("${sample_id}_trimmed_1P.fastq.gz"), path("${sample_id}_trimmed_2P.fastq.gz")

    script:
    """
    trimmomatic PE -threads ${task.cpus} \\
        ${fastq_1} ${fastq_2} \\
        ${sample_id}_trimmed_1P.fastq.gz ${sample_id}_trimmed_1U.fastq.gz \\
        ${sample_id}_trimmed_2P.fastq.gz ${sample_id}_trimmed_2U.fastq.gz \\
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    """
}
