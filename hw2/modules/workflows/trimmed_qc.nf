include { FASTQC } from '../qc'

workflow TRIMMED_QC {
    take:
    ch_trimmed

    main:
    ch_fastqc_trimmed = FASTQC(ch_trimmed)

    emit:
    ch_fastqc_trimmed
}
