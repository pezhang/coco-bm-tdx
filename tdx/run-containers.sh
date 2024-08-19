#!/bin/bash

podman rm sgx-pck-id-retrieval-tool
podman rm tdx-qgs
podman rm pccs

podman run -itd --name sgx-pck-id-retrieval-tool  --net=host  --privileged=true  -v /dev:/dev  -v /proc:/proc  -v /sys:/sys  -v /var/home/core/tdx/etc/network_setting.conf:/opt/intel/sgx-pck-id-retrieval-tool/network_setting.conf  -v /var/home/core/tdx/etc/mpa_registration.conf:/etc/mpa_registration.conf  -v /var/home/core/tdx/backup:/backup  --entrypoint "/usr/bin/sleep"   quay.io/bpradipt/tdx-qgs infinity


podman run -itd --name tdx-qgs  --net=host  --privileged=true  -v /dev:/dev  -v /proc:/proc  -v /sys:/sys  -v  /var/home/core/tdx/etc/sgx_default_qcnl.conf:/etc/sgx_default_qcnl.conf quay.io/bpradipt/tdx-qgs

rm -f pckcache.db
touch pckcache.db
chmod 666 pckcache.db

podman run -itd --name pccs  --net=host  --privileged  -v /var/home/core/tdx/config:/opt/intel/pccs/config  -v /var/home/core/tdx/pckcache.db:/opt/intel/pccs/pckcache.db quay.io/bpradipt/tdx-pccs

