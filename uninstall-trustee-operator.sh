#!/bin/bash
oc delete -f ns.yaml
oc delete -f kbs_catalog-ocp.yaml
oc delete -f og.yaml
oc delete -f subs-ocp.yaml
oc delete -f reference-values.yaml
oc delete secret generic kbsres1
oc delete -f kbs-config.yaml
oc delete -f crd.yaml
