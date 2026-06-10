#!/usr/bin/env nextflow

params.reads = null
params.sra_id = null
params.reference = null
params.threads = 4

include { PREPARE_INPUT      } from './modules/workflows/prepare_input'
include { RAW_QC             } from './modules/workflows/raw_qc'
include { TRIM               } from './modules/workflows/trim'
include { TRIMMED_QC         } from './modules/workflows/trimmed_qc'
include { PREPARE_REFERENCE  } from './modules/workflows/prepare_reference'
include { MAP                } from './modules/workflows/map'
include { PLOT_COVERAGE_WF   } from './modules/workflows/plot_coverage'

workflow {
    main:
    ch_reads = PREPARE_INPUT(params.reads, params.sra_id)
    ch_raw_qc = RAW_QC(ch_reads)
    ch_trimmed = TRIM(ch_reads)
    ch_trimmed_qc = TRIMMED_QC(ch_trimmed)
    ch_ref = PREPARE_REFERENCE(params.reference, ch_trimmed)
    ch_bam = MAP(ch_ref, ch_trimmed)
    ch_plots = PLOT_COVERAGE_WF(ch_ref, ch_bam)

    publish:
    raw_qc      = ch_raw_qc
    trimmed_qc  = ch_trimmed_qc
    assembly    = ch_ref
    mapped_bams = ch_bam
    coverage    = ch_plots
}

output {
    raw_qc {
        path 'raw_qc'
    }
    trimmed_qc {
        path 'trimmed_qc'
    }
    assembly {
        path 'assembly'
    }
    mapped_bams {
        path 'mapped_bams'
    }
    coverage {
        path 'coverage_plots'
    }
}
