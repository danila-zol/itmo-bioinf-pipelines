#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPARE_INPUT      } from './modules/workflows/prepare_input'
include { RAW_QC             } from './modules/workflows/raw_qc'
include { TRIM               } from './modules/workflows/trim'
include { TRIMMED_QC         } from './modules/workflows/trimmed_qc'
include { PREPARE_REFERENCE   } from './modules/workflows/prepare_reference'
include { MAP                } from './modules/workflows/map'
include { PLOT_COVERAGE_WF   } from './modules/workflows/plot_coverage'
include { VARIANT_CALLING    } from './modules/workflows/variant_calling'
include { FILTER_VARIANTS_WF } from './modules/workflows/filter_variants'

workflow {
    main:
    ch_all_samples = PREPARE_INPUT(params.csv)

    ch_group_lookup = ch_all_samples
        .map { sid, group, fq1, fq2 -> [sid, group] }

    ch_reads = ch_all_samples.map { sid, group, fq1, fq2 ->
        tuple(sid, fq1, fq2)
    }

    ch_raw_qc     = RAW_QC(ch_reads)
    ch_trimmed    = TRIM(ch_reads)
    ch_trimmed_qc = TRIMMED_QC(ch_trimmed)
    ch_ref        = PREPARE_REFERENCE(null, ch_trimmed)
    ch_bam        = MAP(ch_ref, ch_trimmed)
    ch_plots      = PLOT_COVERAGE_WF(ch_ref, ch_bam)
    ch_variants   = VARIANT_CALLING(ch_ref, ch_bam)

    ch_keyed   = ch_variants.map { meta, vcf, tbi -> [meta.id, meta, vcf, tbi] }
    ch_tagged  = ch_keyed.join(ch_group_lookup)
        .map { sid, meta, vcf, tbi, group ->
            tuple(meta + [group: group], vcf, tbi)
        }

    ch_grouped_variants = ch_tagged
        .map { meta, vcf, tbi -> [meta.group, meta, vcf, tbi] }
        .groupTuple()

    ch_all_variants = ch_grouped_variants.flatMap { group, metas, vcfs, tbis ->
        [metas, vcfs, tbis].transpose().collect { m, v, t -> tuple(m, v, t) }
    }

    ch_filtered = FILTER_VARIANTS_WF(ch_all_variants)

    publish:
    variants            = ch_all_variants
    filtered_variants   = ch_filtered
}

workflow.onComplete {
    def summary = """
    Pipeline Finished. Success: ${workflow.success}
    Duration: ${workflow.duration}
    Command: ${workflow.commandLine}
    """.stripIndent()
    println summary
    file("${workflow.launchDir}/summary.txt").text = summary
}

workflow.onError {
    file("${workflow.launchDir}/error.log").text = "Failed: ${workflow.errorMessage}"
}