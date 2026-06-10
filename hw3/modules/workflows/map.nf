include { INDEX_REFERENCE } from '../mapping'
include { MAP_READS } from '../mapping'

workflow MAP {
    take:
    ch_ref
    ch_trimmed

    main:
    ch_indexed = INDEX_REFERENCE(ch_ref)

    ch_ref_for_join = ch_indexed.map { ref_tuple ->
        def ref_name = ref_tuple[0]
        def ref_files = ref_tuple[1..-1]
        return [ref_name, ref_files]
    }

    ch_trimmed_for_join = ch_trimmed.map { sample_tuple ->
        def sample_id = sample_tuple[0]
        def sample_files = sample_tuple[1..-1]
        return [sample_id, sample_files]
    }

    ch_combined = ch_ref_for_join.cross(ch_trimmed_for_join)
        .map { cross ->
            def ref_name = cross[0][0]
            def ref_files = cross[0][1]
            def sample_id = cross[1][0]
            def sample_files = cross[1][1]
            return tuple(ref_name, *ref_files, sample_id, *sample_files)
        }

    ch_bam = MAP_READS(ch_combined)

    emit:
    ch_bam
}
