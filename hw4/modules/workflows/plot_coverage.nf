include { PLOT_COVERAGE } from '../plot'

workflow PLOT_COVERAGE_WF {
    take:
    ch_ref
    ch_bam

    main:
    ch_ref_simple = ch_ref.map { ref_tuple ->
        def ref_name = ref_tuple[0]
        def ref_path = ref_tuple[1]
        return [ref_name, ref_path]
    }

    ch_bam_with_sample = ch_bam.map { sample_id, bam, bai ->
        return [sample_id, bam, bai]
    }

    ch_combined = ch_ref_simple.join(ch_bam_with_sample)
        .map { sample_id, ref_path, bam, bai ->
            return tuple(sample_id, ref_path, bam, bai)
        }

    ch_plots = PLOT_COVERAGE(ch_combined)

    emit:
    ch_plots
}
