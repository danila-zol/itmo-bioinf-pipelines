process DOWNLOAD_READS {
    tag "${sra_id}"
    label 'process_low'

    input:
    val(sra_id)

    output:
    tuple val(sra_id), path("${sra_id}_1.fastq.gz"), path("${sra_id}_2.fastq.gz")

    script:
    """
    fasterq-dump --threads ${task.cpus} --split-files --gzip ${sra_id}
    """
}
