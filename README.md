# oci-quickstart-prerequisites

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
VERSION='0.11.10' # latest, stable version
wget "https://releases.hashicorp.com/terraform/"$VERSION"/terraform_"$VERSION"_linux_amd64.zip"
unzip terraform_0.11.10_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chown root:root /usr/local/bin/terraform
```

</details>

<details><summary>Windows</summary>

The easiest way to install Terraform and run other setup is to install [Chocolatey](https://chocolatey.org/), which is a package manager for windows.
You can then use Chocolatey to install Terraform and Git for Windows (which includes other needed tools).

Start powershell **as Administrator** and run the commands below. `choco` will prompt to install, press `Y` and enter.

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install terraform
choco install git.install --params "/GitAndUnixToolsOnPath /NoAutoCrlf"
```

After this completes close this powershell. These commands have installed Terraform, git, and other utilities we'll use later.

</details>


Regardless of the OS, you can test that the install was successful by running the command:

    terraform

You should see something like:

![](./images/1%20-%20terraform.png)

In the past you needed to manually install the OCI Terraform Provider.  However, OCI is now integrated into the Terraform executable, so that's no longer necessary!


## Setup Keys
We need to create an SSH keypair for connecting to VM instances by following [these instructions](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).  Then create a key for OCI API access by following the instructions [here](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).

You really just need to run the commands below in a terminal or regular powershell (**not** as Administrator):

<details><summary>macOS or Linux</summary>

```
ssh-keygen -t rsa -N "" -b 2048 -f ~/.ssh/oci
mkdir ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

</details>

<details><summary>Windows</summary>

```
cd ~\
md .ssh
ssh-keygen --% -t rsa -N "" -b 2048 -f .\.ssh\oci
md .oci
openssl genrsa -out .\.oci\oci_api_key.pem 2048
openssl rsa -pubout -in .\.oci\oci_api_key.pem -out .\.oci\oci_api_key_public.pem
```

</details>

The output of `openssl` can be slightly different between OS's when generating the fingerprint of the public key. Run one of the following to make a correctly formatted fingerprint and to copy the public key to paste into the OCI console.

<details><summary>macOS</summary>

```
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c > ~/.oci/oci_api_key.fingerprint
cat ~/.oci/oci_api_key_public.pem | pbcopy
```
</details>

<details><summary>Linux</summary>

```
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c | awk '{print $2}' > ~/.oci/oci_api_key.fingerprint
cat ~/.oci/oci_api_key_public.pem | xclip -selection clipboard
```
</details>

<details><summary>Windows</summary>

```
cd ~\
openssl rsa -pubout -outform DER -in .oci\oci_api_key.pem -out key.tmp
openssl md5 -c key.tmp | awk '{print $2}' | Out-File -Encoding ASCII -NoNewline .\.oci\oci_api_key.fingerprint
del key.tmp
Get-Content (Resolve-Path ".\.oci\oci_api_key_public.pem") -Raw -Encoding ASCII | clip.exe
```
</details>

Open a web browser to the console [here](https://console.us-phoenix-1.oraclecloud.com/a/identity/users).  Then select your user, click "Add Public Key" and paste it into the dialog.

![](./images/3%20-%20console.png)

## Setup Environment Variables
Now, let's take a look at the [env-vars.sh](env-vars.sh) file for macOS and [env-vars.ps1](env-vars.ps1) for Windows. You don't have to clone this repo to get the file, you can just run either:
```
curl -o ~/env-vars.sh https://raw.githubusercontent.com/cloud-partners/oci-prerequisites/master/env-vars.sh
# or
curl -o ~/env-vars.ps1 https://raw.githubusercontent.com/cloud-partners/oci-prerequisites/master/env-vars.ps1

```

![](./images/4%20-%20env-vars.png)

The script pulls values from the keys you created in the earlier steps.  You'll need to update three fields with values you can find in the [console](https://console.us-phoenix-1.oraclecloud.com/):

* TF_VAR_compartment_ocid
* TF_VAR_tenancy_ocid
* TF_VAR_user_ocid

When you've set all the variables, on macOs/Linux you can source the file with the command `source ~/env-vars.sh` or you could stick the contents of the file in `~/.bash_profile`

On Windows run `Set-ExecutionPolicy Bypass -Scope Process -Force; ~\env-vars.ps1`. Note, for every new powershell terminal you open these environment variables need to be created by running the above for Terraform commands to work.

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
