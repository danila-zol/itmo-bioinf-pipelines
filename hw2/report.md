The pipeline was implemented as a modular Nextflow workflow using named sub-workflows (`take:` / `emit:`), as demonstrated in the course materials.

It was tested on the **SRR37880700** influenza genome dataset. The run was performed using local paired-end FASTQ files with de novo assembly mode.

To generate the analysis results, the pipeline was executed with the following arguments:
```
$ nextflow run main.nf \
    --reads '*_{1,2}.fastq.gz' \
    -output-dir results_local \
    --threads 4
```

## Pipeline Overview

The pipeline consists of the following named workflows:

1. **PREPARE_INPUT** — Reads local FASTQ files or downloads them from NCBI SRA using `fasterq-dump`.
2. **RAW_QC** — Runs **FastQC** on raw reads to assess initial quality.
3. **TRIM** — Trims adapters and low-quality bases using **Trimmomatic** (`LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36`).
4. **TRIMMED_QC** — Runs **FastQC** again on the trimmed reads.
5. **PREPARE_REFERENCE** — Either uses a provided reference genome or performs de novo assembly with **SPAdes** (tested in de novo mode).
6. **MAP** — Indexes the reference with **BWA** and maps the trimmed reads using **BWA-MEM**, producing sorted and indexed BAM files.
7. **PLOT_COVERAGE_WF** — Generates per-contig coverage plots using `samtools depth` and **matplotlib**.

## General Statistics

The pipeline successfully processed the SRR37880700 dataset (~2.8 MB + ~2.9 MB compressed FASTQ).

* **Raw QC**: Both forward and reverse reads showed good base quality. FastQC reports were generated for `SRR37880700_1` and `SRR37880700_2`.
* **Trimming**: Trimmomatic produced paired trimmed reads (`SRR37880700_trimmed_1P.fastq.gz` and `SRR37880700_trimmed_2P.fastq.gz`). Unpaired reads were discarded.
* **Trimmed QC**: Post-trimming FastQC confirmed improved quality profiles with adapter contamination removed.
* **De Novo Assembly**: SPAdes assembled the reads into **269 contigs** (saved as `SRR37880700_assembly.fasta`). The largest contig was 7,658 bp with a coverage of ~16.9x.
* **Mapping**: BWA-MEM mapped the trimmed reads back to the assembled reference. The resulting sorted BAM and index were published to `mapped_bams/`.
* **Coverage Plots**: Per-contig coverage plots were generated for all 269 contigs and saved to `coverage_plots/`. Coverage ranged from near-zero to several thousand-fold for small high-copy contigs (e.g., `NODE_269_length_78_cov_18977`).

## Output Structure

```
results_local/
├── raw_qc/
│   ├── SRR37880700_1_fastqc.html
│   ├── SRR37880700_1_fastqc.zip
│   ├── SRR37880700_2_fastqc.html
│   └── SRR37880700_2_fastqc.zip
├── trimmed_qc/
│   ├── SRR37880700_trimmed_1P_fastqc.html
│   ├── SRR37880700_trimmed_1P_fastqc.zip
│   ├── SRR37880700_trimmed_2P_fastqc.html
│   └── SRR37880700_trimmed_2P_fastqc.zip
├── assembly/
│   └── SRR37880700_assembly.fasta
├── mapped_bams/
│   ├── SRR37880700_mapped_sorted.bam
│   └── SRR37880700_mapped_sorted.bam.bai
└── coverage_plots/
    ├── SRR37880700_NODE_1_length_7658_cov_16.928242_coverage.png
    ├── ...
    └── SRR37880700_NODE_269_length_78_cov_18977.000000_coverage.png
```

## Additional Test: Provided Reference Mode

The pipeline was also tested using a pre-assembled reference instead of de novo assembly to verify the `params.reference` branch:

```
$ nextflow run main.nf \
    --reads '*_{1,2}.fastq.gz' \
    --reference results_local/assembly/SRR37880700_assembly.fasta \
    -output-dir results_ref \
    --threads 4
```

This run completed successfully, producing identical output categories (QC, mapping, and coverage plots) without re-running the assembly step.

## Conclusion

The implemented pipeline fulfills all required steps: input preparation, raw QC, trimming, trimmed QC, reference preparation (de novo or provided), mapping, and coverage plotting. All steps are encapsulated in named workflows compatible with the Nextflow DSL2 syntax. The generated reference, coverage plots and other files are commited into hw2/results_local directory
