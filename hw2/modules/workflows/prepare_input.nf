include { DOWNLOAD_READS } from '../download'

workflow PREPARE_INPUT {
    take:
    reads_param
    sra_param

    main:
    if (reads_param) {
        ch_reads = Channel
            .fromFilePairs(reads_param, size: 2)
            .map { sample_id, fastqs -> tuple(sample_id, fastqs[0], fastqs[1]) }
    } else if (sra_param) {
        ch_reads = DOWNLOAD_READS(sra_param)
    } else {
        error "Either params.reads or params.sra_id must be provided."
    }

    emit:
    ch_reads
}
