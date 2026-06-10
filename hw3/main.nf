#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREPARE_INPUT      } from './modules/workflows/prepare_input'
include { RAW_QC             } from './modules/workflows/raw_qc'
include { TRIM               } from './modules/workflows/trim'
include { TRIMMED_QC         } from './modules/workflows/trimmed_qc'
include { PREPARE_REFERENCE  } from './modules/workflows/prepare_reference'
include { MAP                } from './modules/workflows/map'
include { PLOT_COVERAGE_WF   } from './modules/workflows/plot_coverage'
include { VARIANT_CALLING    } from './modules/workflows/variant_calling'

workflow {
    main:
    ch_reads = PREPARE_INPUT(params.reads, params.sra_id)
    ch_raw_qc = RAW_QC(ch_reads)
    ch_trimmed = TRIM(ch_reads)
    ch_trimmed_qc = TRIMMED_QC(ch_trimmed)
    ch_ref = PREPARE_REFERENCE(params.reference, ch_trimmed)
    ch_bam = MAP(ch_ref, ch_trimmed)
    ch_plots = PLOT_COVERAGE_WF(ch_ref, ch_bam)
    ch_variants = VARIANT_CALLING(ch_ref, ch_bam)

    publish:
    raw_qc      = ch_raw_qc
    trimmed_qc  = ch_trimmed_qc
    assembly    = ch_ref
    mapped_bams = ch_bam
    coverage    = ch_plots
    variants    = ch_variants
}

output {
    raw_qc {
        path "${params.output_dir}/raw_qc"
    }
    trimmed_qc {
        path "${params.output_dir}/trimmed_qc"
    }
    assembly {
        path "${params.output_dir}/assembly"
    }
    mapped_bams {
        path "${params.output_dir}/mapped_bams"
    }
    coverage {
        path "${params.output_dir}/coverage_plots"
    }
    variants {
        path "${params.output_dir}/variants"
    }
}
