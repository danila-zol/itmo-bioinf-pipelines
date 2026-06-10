process FASTQC {
    tag "${sample_id}"
    label 'process_low'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)

    output:
    path "*_fastqc.{zip,html}"

    script:
    """
    fastqc -t ${task.cpus} ${fastq_1} ${fastq_2}
    """
}
