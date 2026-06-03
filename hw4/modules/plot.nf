process PLOT_COVERAGE {
    tag "${sample_id}"
    label 'process_low'

    input:
    tuple val(sample_id), path(reference), path(bam), path(bai)

    output:
    path "*_coverage.png"

    script:
    """
    samtools faidx ${reference}
    cut -f1 ${reference}.fai > contigs.txt

    python3 << 'PYEOF'
import os
import subprocess
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

sample_id = "${sample_id}"
bam_file  = "${bam}"

with open("contigs.txt", 'r') as f:
    contigs = [line.strip() for line in f if line.strip()]

for contig in contigs:
    result = subprocess.run(
        ["samtools", "depth", "-r", contig, bam_file],
        capture_output=True, text=True
    )
    data = result.stdout.strip().splitlines()
    positions = []
    depths = []
    for line in data:
        parts = line.split()
        if len(parts) == 3:
            positions.append(int(parts[1]))
            depths.append(int(parts[2]))
    if positions:
        plt.figure(figsize=(12, 4))
        plt.plot(positions, depths, linewidth=0.8)
        plt.xlabel('Position')
        plt.ylabel('Depth')
        plt.title(f'Coverage: {contig}')
        plt.tight_layout()
        safe_name = contig.replace(' ','_').replace('/','_')
        out_path = f'{sample_id}_{safe_name}_coverage.png'
        plt.savefig(out_path, dpi=150)
        plt.close()
        print(f"Saved plot {out_path}", flush=True)

print("Coverage plotting complete.", flush=True)
PYEOF
    """
}
