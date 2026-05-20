set -e

USER="danilazol"
TAG="latest"

cd "$(dirname "$0")"

echo "Building bioinf-qc..."
docker build -t ${USER}/bioinf-qc:${TAG} -f Dockerfile.qc .

echo "Building bioinf-assembly..."
docker build -t ${USER}/bioinf-assembly:${TAG} -f Dockerfile.assembly .

echo "Building bioinf-mapping..."
docker build -t ${USER}/bioinf-mapping:${TAG} -f Dockerfile.mapping .

echo "Building bioinf-variant..."
docker build -t ${USER}/bioinf-variant:${TAG} -f Dockerfile.variant .

echo "Building bioinf-plot..."
docker build -t ${USER}/bioinf-plot:${TAG} -f Dockerfile.plot .

echo "Pushing images..."
docker push ${USER}/bioinf-qc:${TAG}
docker push ${USER}/bioinf-assembly:${TAG}
docker push ${USER}/bioinf-mapping:${TAG}
docker push ${USER}/bioinf-variant:${TAG}
docker push ${USER}/bioinf-plot:${TAG}

echo "Done."
