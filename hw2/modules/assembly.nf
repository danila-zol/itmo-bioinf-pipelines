process ASSEMBLE {
    tag "${sample_id}"
    label 'process_high'

    input:
    tuple val(sample_id), path(fastq_1), path(fastq_2)

    output:
    tuple val(sample_id), path("${sample_id}_assembly.fasta")

    script:
    """
    spades.py -1 ${fastq_1} -2 ${fastq_2} -t ${task.cpus ?: 4} -o spades_out
    if [ -f spades_out/scaffolds.fasta ]; then
        cp spades_out/scaffolds.fasta ${sample_id}_assembly.fasta
    elif [ -f spades_out/contigs.fasta ]; then
        cp spades_out/contigs.fasta ${sample_id}_assembly.fasta
    else
        echo ">${sample_id}_empty" > ${sample_id}_assembly.fasta
        echo "NNNNN" >> ${sample_id}_assembly.fasta
    fi
    """
}
