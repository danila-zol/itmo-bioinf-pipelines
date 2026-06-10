include { FASTQC as FASTQC_TRIMMED } from '../qc'

workflow TRIMMED_QC {
    take:
    ch_trimmed

    main:
    ch_fastqc_trimmed = FASTQC_TRIMMED(ch_trimmed)

    emit:
    ch_fastqc_trimmed
}
