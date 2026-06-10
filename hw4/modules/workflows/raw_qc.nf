include { FASTQC as FASTQC_RAW } from '../qc'

workflow RAW_QC {
    take:
    ch_reads

    main:
    ch_fastqc_raw = FASTQC_RAW(ch_reads)

    emit:
    ch_fastqc_raw
}
