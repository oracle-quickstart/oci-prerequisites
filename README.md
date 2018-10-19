# oci-prerequisites

This README describes the steps to setup your environment so it can run Terraform modules on OCI.

## Create an OCI Account
If you don't have an OCI account, you can sign up for a free trial [here](https://cloud.oracle.com/en_US/tryit).  The free trial only has the Ashburn region enabled by default.  Depending on what Terraform modules you're going to deploy, you may need to enable other regions.  Similarly, the default quotas are pretty low, so you might need to request increases.

## Install Terraform

Now, we need to install Terraform.  Instructions on that are [here](https://www.terraform.io/intro/getting-started/install.html).  Of course, I'm on a Mac, and like to do things the easy way, so I installed [brew](https://brew.sh/) and then used it to install Terraform with the commands:

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    sudo chown -R $(whoami) /usr/local/bin /usr/local/lib
    brew install terraform

You can test that the install was successful by running the command:

    terraform

You should see something like:

![](./images/1%20-%20terraform.png)

In the past you needed to manually install the OCI Terraform Provider.  However, OCI is now integrated into the Terraform executable, so that's no longer necessary!

## Setup Keys
Create an SSH keypair for connecting to VM instances by follow [these instructions](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).  You really just need to do this:

    ssh-keygen -t rsa -N "" -b 2048 -f ~/.ssh/oci

Now, create a key for OCI API access by following the instructions [here](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).  Basically, you need to run these commands:

    mkdir ~/.oci
    openssl genrsa -out ~/.oci/oci_api_key.pem 2048
    openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
    openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c > ~/.oci/oci_api_key.fingerprint
    cat ~/.oci/oci_api_key_public.pem | pbcopy

When complete, open a web browser to the console [here](https://console.us-phoenix-1.oraclecloud.com/a/identity/users).  Then select your user, click "Add Public Key" and paste it into the dialog.

![](./images/3%20-%20console.png)

## Setup Environment Variables
Now, let's take a look at the [env-vars.sh](env-vars.sh) file.

![](./images/4%20-%20env-vars.png)

The script pulls values from the keys you created in the earlier steps.  You'll need to update three fields with values you can find in the [console](https://console.us-phoenix-1.oraclecloud.com/):

* TF_VAR_compartment_ocid
* TF_VAR_tenancy_ocid
* TF_VAR_user_ocid

When you've set all the variables, you can source the file with the command `source env-vars.sh` or you could stick the contents of the file in `~/.bash_profile`

With that, you're all ready to start running Terraform commands!

## Create SSH Config
With the current setup you can SSH to a machine with the command:

    ssh -i ~/.ssh/oci <username>@<ip_address>

If we add a ssh_config file, we can simplify that a bit.  To create that file, run the command:

    echo "Host *
      IdentityFile ~/.ssh/oci
      User opc" > ~/.ssh/config

Now you can SSH to your OEL machines on OCI with the command:

    ssh <ip_address>
