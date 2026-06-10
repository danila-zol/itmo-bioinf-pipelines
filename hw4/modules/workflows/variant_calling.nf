include { BCFTOOLS_MPILEUP } from '../bcftools'
include { BCFTOOLS_CALL } from '../bcftools'

workflow VARIANT_CALLING {
    take:
    ch_ref
    ch_bam

    main:
    ch_ref_simple = ch_ref.map { ref_tuple ->
        def ref_name = ref_tuple[0]
        def ref_path = ref_tuple[1]
        tuple([id: ref_name, single_end: false], ref_path)
    }

    ch_bam_with_meta = ch_bam.map { sample_id, bam, bai ->
        tuple([id: sample_id, single_end: false], bam, bai)
    }

    ch_bam_key = ch_bam_with_meta.map { meta, bam, bai ->
        [meta.id, meta, bam, bai]
    }
    ch_ref_key = ch_ref_simple.map { meta2, fasta ->
        [meta2.id, meta2, fasta]
    }

    ch_joined = ch_bam_key.join(ch_ref_key)

    ch_bam_input = ch_joined.map { id, meta, bam, bai, meta2, fasta ->
        tuple(meta, bam, bai)
    }

    ch_ref_input = ch_joined.map { id, meta, bam, bai, meta2, fasta ->
        tuple(meta2, fasta)
    }

    ch_mpileup = BCFTOOLS_MPILEUP(ch_bam_input, ch_ref_input)
    ch_variants = BCFTOOLS_CALL(ch_mpileup)

    emit:
    ch_variants
}
