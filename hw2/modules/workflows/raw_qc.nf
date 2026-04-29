include { FASTQC } from '../qc'

workflow RAW_QC {
    take:
    ch_reads

    main:
    ch_fastqc_raw = FASTQC(ch_reads)

    emit:
    ch_fastqc_raw
}
