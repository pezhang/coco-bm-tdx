# Install OpenShift sandboxed containers operator with kata-cc-tdx enabled
./coco_install.sh

# Check if container can start up with kata-cc-tdx
./check_tdx.sh

# Uploads your local ssh pulic key to the worker node
./login_worker.sh

# Start qgs and pccs service in the worker node to get evidence
./start_qgs_pccs.sh

# Check if we can get evidence inside the container
./check_evidence_getter.sh


