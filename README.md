# oci-prerequisites

This README describes the steps to setup your environment so it can run Terraform modules on OCI.

## Create an OCI Account
If you don't have an OCI account, you can sign up for a free trial [here](https://cloud.oracle.com/en_US/tryit).  The free trial only has the Ashburn region enabled by default.  Depending on what Terraform modules you're going to deploy, you may need to enable other regions.  Similarly, the default quotas are pretty low, so you might need to request increases.

## Install Terraform

Now, we need to install Terraform.  Instructions on that are [here](https://www.terraform.io/intro/getting-started/install.html).  You can test that the install was successful by running the command:

    terraform

You should see something like:

![](./images/1%20-%20terraform.png)

## Install the OCI Provider

Next you're going to need to install the [Terraform Provider for Oracle Cloud Infrastructure](https://github.com/oracle/terraform-provider-baremetal/blob/master/README.md).  I'm on a Mac, so I downloaded a copy of the binary, `darwin_amd64.tar.gz` from [here](https://github.com/oracle/terraform-provider-oci/releases) and put it in a new plugins directory.  To do that, I ran the following commands:

    cd ~/.terraform.d
    mkdir plugins
    cd plugins
    curl -L https://github.com/oracle/terraform-provider-oci/releases/download/v2.2.1/darwin_amd64.tar.gz > darwin_amd64.tar.gz
    tar -xvf darwin_amd64.tar.gz
    rm darwin_amd64.tar.gz
    ls

That gave this output:

![](./images/2%20-%20provider.png)

## Setup Keys
Create an SSH keypair for connecting to VM instances by follow [these instructions](https://docs.us-phoenix-1.oraclecloud.com/Content/GSG/Tasks/creatingkeys.htm).  You really just need to do this:

    ssh-keygen -t rsa -N "" -b 2048 -f ~/.ssh/oci

Now, create a key for OCI API access by following the instructions [here](https://docs.us-phoenix-1.oraclecloud.com/Content/API/Concepts/apisigningkey.htm).  Basically, you need to run these commands:

    mkdir ~/.oci
    openssl genrsa -out ~/.oci/oci_api_key.pem 2048
    openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
    cat ~/.oci/oci_api_key_public.pem | pbcopy

When complete, open a web browser to the console [here](https://console.us-phoenix-1.oraclecloud.com/a/identity/users).  Then select your user, click "Add Public Key" and paste it into the dialog.

![](./images/3%20-%20console.png)

## Setup Environment Variables
Now, let's take a look at the `env-vars` file.

![](./images/4%20-%20env-vars.png)

The script pulls values from the keys you created in the earlier steps.  You'll need to update two fields with values you can find in the [console](https://console.us-phoenix-1.oraclecloud.com/):

* TF_VAR_tenancy_ocid
* TF_VAR_user_ocid

When you've set all the variables, you can source the file with the command `source env-vars` or you could stick the contents of the file in `~/.bash_profile`

With that, you're all ready to start running Terraform commands!
