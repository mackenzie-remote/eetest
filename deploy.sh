#!/bin/bash
set -euo pipefail

readonly SUBMODULE_DIR="docker-helloworld-python-microservice"
readonly DEPS="docker kubectl minikube"

missingdep() {
  echo "[!!] Missing dependency $1. Please install $1 and rerun this script to continue."
  exit 1
}

startminikube() {
  echo "[..] Attempting to start Minikube (this may take some time).."
  minikube start
  echo "[OK] Minikube started."
}

# Check dependencies before Continuing
# FIXME: Perhaps loop around all of them rather than exiting on the first failure
# FIXME: Give a URL / hint? Currently just in the README.
echo -en "[..] Checking dependencies.."
for DEP in ${DEPS}; do
  which ${DEP} >/dev/null 2>&1 || missingdep ${DEP}
  echo -en " ${DEP}"
done

echo -en "\n[OK] Dependencies are present. Continuing..\n"

# Check minikube status to see if it's running, if not start it..
echo "[..] Checking if Minikube is running already.."
if minikube status; then
  echo "[OK] Minikube is already running."
else
  startminikube
fi

# Build the helloworld docker image. (1/2)
echo "[..] Checking if '${SUBMODULE_DIR}' directory exists..'"
if [ ! -d ${SUBMODULE_DIR} ]; then
  echo "[!!] The '${SUBMODULE_DIR}' directory does not exist!"
  echo "     This is a git submodule - please ensure that you have cloned the repo (not downloaded the zip)"
  echo "     and try running the command 'git submodule update --recursive --remote'"
  exit 1
fi
echo "[OK] Directory '${SUBMODULE_DIR}' exists."

# Build the helloworld docker image. (2/2)
# This magic lets control the docker daemon running on the minikube instance
eval $(minikube docker-env)

cd "${SUBMODULE_DIR}"
echo "[..] Building the docker image on the minikube instance.."
docker build -t helloworld:latest .
echo "[OK] Image built"

echo "[..] Running kubectl apply to create the helloworld deployment and service"
cd - >/dev/null
kubectl apply -f helloworld.yaml
kubectl get pods -o wide

echo "[OK] Creating port-forward - this can be CTRL+C'd to exit."
echo ""
echo "     === Browse to http://localhost:8080 to access the Hello World. ==="
echo ""
# Loop needed to workaround bug in kubectl pod-running-timeout
# https://github.com/kubernetes/kubernetes/issues/62821
for TRY in $(seq 30); do
  echo "[..] Trying to set up port-forward (attempt ${TRY} of 30).."
  kubectl port-forward deployment/helloworld 8080 || true
  sleep 2
done
