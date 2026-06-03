# HW4

The hw3 pipeline was extended with data-driven multi-sample support, scatter/gather grouping, and a downstream variant filtering process with stub-run support.

## New Features

1. **Multi-sample CSV input** — Reads `samples.csv` via `.splitCsv(header: true)`. The CSV defines sample id, group, and paired FASTQ paths. Adding a new sample or group requires only a new CSV row — no code changes.
2. **Scatter by group** — A data-driven lookup (`sample_id → group`) is built from the CSV. Each sample flows independently through the full assembly→mapping→variant calling pipeline. The group field is reattached post-hoc via `.join()` on `sample_id`.
3. **Gather by group** — Results are grouped using `.groupTuple()` keyed on the (now dynamic) `meta.group` field, then flattened back to individual tuples. Zero hardcoded group names or sample IDs remain.
4. **FILTER_VARIANTS process with stub** — A new `bcftools filter` process filters variants by QUAL≥20. It includes a `stub:` block for dry-run design and testing with `-stub-run`.
5. **Lifecycle handlers** — `workflow.onComplete` writes `summary.txt`; `workflow.onError` writes `error.log`.

## Test Data

Two Influenza targeted sequencing runs were chosen.

| Sample | Group | Reads |
|---|---|---|
| SRR37880700 | fluA | 2.9 + 3.0 MB |
| SRR36813205 | fluB | 10.2 + 10.7 MB |

Downloaded using SRA Toolkit:

```bash
fasterq-dump --split-files SRR37880700
&& fasterq-dump --split-files SRR36813205
```

## Execution

```
$ nextflow run . -profile local --csv ./samples.csv
```

Result: **20/20 processes succeeded** in ~12 minutes.

## Results

| Sample | Variants | Filtered (QUAL≥20) |
|---|---|---|
| SRR37880700 | 910 | 434 |
| SRR36813205 | 3599 | 1894 |

## Output Structure

```
results/
├── variants/
│   ├── SRR37880700_variants.vcf.gz
│   ├── SRR37880700_variants.vcf.gz.tbi
│   ├── SRR36813205_variants.vcf.gz
│   └── SRR36813205_variants.vcf.gz.tbi
└── filtered_variants/
    ├── SRR37880700_filtered.vcf.gz
    ├── SRR37880700_filtered.vcf.gz.tbi
    ├── SRR36813205_filtered.vcf.gz
    └── SRR36813205_filtered.vcf.gz.tbi
```

## Input Format (`samples.csv`)

```csv
id,group,fastq_1,fastq_2
SRR37880700,fluA,./SRR37880700_1.fastq.gz,./SRR37880700_2.fastq.gz
SRR36813205,fluB,./SRR36813205_1.fastq.gz,./SRR36813205_2.fastq.gz
```

## Pipeline Steps

1. **PREPARE_INPUT** — CSV parsing with `.splitCsv`
2. **RAW_QC** — FastQC on raw reads
3. **TRIM** — Trimmomatic adapter/quality trimming
4. **TRIMMED_QC** — FastQC on trimmed reads
5. **PREPARE_REFERENCE** — De novo assembly with SPAdes (no external reference)
6. **MAP** — BWA index + BWA-MEM mapping + samtools sort/index
7. **PLOT_COVERAGE_WF** — Per-contig coverage plots via matplotlib
8. **VARIANT_CALLING** — bcftools mpileup + bcftools call
9. **FILTER_VARIANTS** — QUAL≥20 filtering with stub support
