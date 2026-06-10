include { DOWNLOAD_READS } from '../download'

workflow PREPARE_INPUT {
    take:
    csv_param

    main:
    if (csv_param) {
        ch_reads = Channel
            .fromPath(csv_param, checkIfExists: true)
            .splitCsv(header: true)
            .map { row ->
                def sample_id = row.id
                def group     = row.group
                def fq1       = file(row.fastq_1)
                def fq2       = file(row.fastq_2)
                return tuple(sample_id, group, fq1, fq2)
            }
    } else {
        error "params.csv must point to a valid CSV file."
    }

    emit:
    ch_reads
}