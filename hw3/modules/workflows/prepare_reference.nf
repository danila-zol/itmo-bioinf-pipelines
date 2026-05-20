include { ASSEMBLE } from '../assembly'

workflow PREPARE_REFERENCE {
    take:
    reference_param
    ch_reads

    main:
    if (reference_param) {
        def ref_path = file(reference_param)
        ch_ref = ch_reads.map { sample_id, fastq1, fastq2 -> tuple(sample_id, ref_path) }
    } else {
        ch_ref = ASSEMBLE(ch_reads)
    }

    emit:
    ch_ref
}
