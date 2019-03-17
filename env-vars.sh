#!/bin/sh

# Required for the OCI Provider
export TF_VAR_tenancy_ocid="<tenancy OCID>"
export TF_VAR_compartment_ocid="<compartment OCID>"
export TF_VAR_user_ocid="<user OCID>"
export TF_VAR_fingerprint=$(cat ~/.oci/oci_api_key.fingerprint)
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_region="us-ashburn-1"

# Keys used to SSH to OCI VMs
export TF_VAR_ssh_public_key=$(cat ~/.ssh/oci.pub)
export TF_VAR_ssh_private_key=$(cat ~/.ssh/oci)
