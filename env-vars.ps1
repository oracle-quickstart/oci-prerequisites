# to source this file run:
# Set-ExecutionPolicy Bypass -Scope Process -Force; .\env-vars.ps1

$env:TF_VAR_compartment_ocid="<compartment OCID>"

# Required for the OCI Provider
$env:TF_VAR_tenancy_ocid="<tenancy OCID>"
$env:TF_VAR_user_ocid="<user OCID>"
$env:TF_VAR_fingerprint=$(cat ~/.oci/oci_api_key.fingerprint)
$env:TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
$env:TF_VAR_region="us-ashburn-1"

# Keys used to SSH to OCI VMs
$env:TF_VAR_ssh_public_key=$(cat ~/.ssh/oci.pub)
$env:TF_VAR_ssh_private_key=$(cat ~/.ssh/oci)
