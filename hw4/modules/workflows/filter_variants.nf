include { FILTER_VARIANTS } from '../variant_filter'

workflow FILTER_VARIANTS_WF {
    take:
    ch_variants

    main:
    ch_filtered = FILTER_VARIANTS(ch_variants)

    emit:
    ch_filtered
}