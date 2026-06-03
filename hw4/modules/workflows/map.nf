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

    ch_combined = ch_ref_for_join.join(ch_trimmed_for_join)
        .map { sample_id, ref_files, sample_files ->
            return tuple(sample_id, *ref_files, sample_id, *sample_files)
        }

    ch_bam = MAP_READS(ch_combined)

    emit:
    ch_bam
}
