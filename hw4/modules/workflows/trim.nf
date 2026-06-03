include { TRIM_READS } from '../trim'

workflow TRIM {
    take:
    ch_reads

    main:
    ch_trimmed = TRIM_READS(ch_reads)

    emit:
    ch_trimmed
}
