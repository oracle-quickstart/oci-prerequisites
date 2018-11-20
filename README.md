# oci-prerequisites

This README describes the steps to setup your environment so it can run Terraform modules on OCI.

## Create an OCI Account
If you don't have an OCI account, you can sign up for a free trial [here](https://cloud.oracle.com/en_US/tryit).  The free trial only has the Ashburn region enabled by default.  Depending on what Terraform modules you're going to deploy, you may need to enable other regions.  Similarly, the default quotas are pretty low, so you might need to request increases.

## Install Terraform

Now, we need to install Terraform.  Instructions on that are [here](https://www.terraform.io/intro/getting-started/install.html).  Depending on which OS you run the installation is slightly different:

<details><summary>macOS</summary>

The easiest way is to install [brew](https://brew.sh/) and then used it to install Terraform with the commands:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib
brew install terraform
```

</details>

<details><summary>Linux</summary>

For installing on Linux, just run:

```
sudo apt-get install -y unzip
VERSION='0.11.10' # latest, stable version
wget "https://releases.hashicorp.com/terraform/"$VERSION"/terraform_"$VERSION"_linux_amd64.zip"
unzip terraform_0.11.10_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chown root:root /usr/local/bin/terraform
```

</details>

<details><summary>Windows (WSL)</summary>

The easiest way to install terraform and run other setup is actually to install Linux. Windows Subsystem for Linux (WSL) is no longer in beta and gives you a complete Linux environment. Complete instructions are [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10), but briefly:

* Start PowerShell as Administrator and run: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux` _**Note, this requires a reboot.**_
* Open the Windows Store and install your desired distro, e.g. Ubuntu 18.04 LTS. This download is approximately 200MB.
* Launch WSL when the download finishes, and when prompted enter a user/password for the newly created Linux user.
* _**Note**_, all subsequent commands are run in the WSL terminal.

Copy the commands below and right click to paste them into the WSL terminal. _**Note**_, this will prompt for the password you just entered.

```
sudo apt-get update
sudo apt-get install -y unzip
VERSION='0.11.10' # latest, stable version
wget "https://releases.hashicorp.com/terraform/"$VERSION"/terraform_"$VERSION"_linux_amd64.zip"
unzip terraform_0.11.10_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chown root:root /usr/local/bin/terraform
```

</details>


Regardless of the OS, you can test that the install was successful by running the command:

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

The output of `openssl` can be slightly different between OS's when generating the fingerprint of the public key. Run one of the following to make a correctly formatted fingerprint and to copy the public key into the OCI console.

<details><summary>macOS</summary>

```

openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c > ~/.oci/oci_api_key.fingerprint
cat ~/.oci/oci_api_key_public.pem | pbcopy
```
</details>

<details><summary>Linux</summary>


```
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem 2>/dev/null | openssl md5 -c | awk '{print $2}' > ~/.oci/oci_api_key.fingerprint
cat ~/.oci/oci_api_key_public.pem | xclip -selection clipboard
```
</details>

<details><summary>Windows (WSL)</summary>
Opening files or copy/pasting between Windows and WSL can introduce carraige returns or whitespace. The following will copy the public key to your Windows desktop and open it with Notepad to copy.

```
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem 2>/dev/null | openssl md5 -c | awk '{print $2}' > ~/.oci/oci_api_key.fingerprint
NAME=$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')
cp ~/.oci/oci_api_key_public.pem /mnt/c/Users/$NAME/Desktop
```
</details>

Open a web browser to the console [here](https://console.us-phoenix-1.oraclecloud.com/a/identity/users).  Then select your user, click "Add Public Key" and paste it into the dialog.

![](./images/3%20-%20console.png)

## Setup Environment Variables
Now, let's take a look at the [env-vars.sh](env-vars.sh) file. You don't have to clone this repo to get the file, you can just run:
```
wget https://raw.githubusercontent.com/cloud-partners/oci-prerequisites/master/env-vars.sh
```

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
