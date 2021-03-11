# Installation Quickstart

- [Installation Quickstart](#installation-quickstart)
  - [Download the Automation Code](#download-the-automation-code)
  - [Setup Terraform Variables](#setup-terraform-variables)
  - [Start Install](#start-install)
  - [Post Install](#post-install)
      - [Delete Bootstrap Node](#delete-bootstrap-node)
      - [Create API and Ingress DNS Records](#create-api-and-ingress-dns-records)
  - [Cluster Access](#cluster-access)
    - [Using CLI](#using-cli)
    - [Using Web UI](#using-web-ui)
  - [Clean up](#clean-up)


## Download the Automation Code

You'll need to use git to clone the deployment code when working off the master branch
```
git clone https://github.com/ocp-power-automation/ocp4-upi-kvm.git
cd ocp4_upi_kvm
```

All further instructions assumes you are in the code directory eg. `ocp4-upi-kvm`

## Setup Terraform Variables

Update the [var.tfvars](../var.tfvars) based on your environment. Description of the variables are available in the following [link](./var.tfvars-doc.md).
You can use environment variables for sensitive data that should not be saved to disk.

```
$ set +o history
$ export RHEL_SUBS_USERNAME=xxxxxxxxxxxxxxx
$ export RHEL_SUBS_PASSWORD=xxxxxxxxxxxxxxx
$ set -o history
```


## Start Install

Run the following commands from within the directory.

```
$ terraform init
$ terraform apply -var-file var.tfvars
```
If using environment variables for sensitive data, then do the following, instead.
```
$ terraform init
$ terraform apply -var-file var.tfvars -var rhel_subscription_username="$RHEL_SUBS_USERNAME" -var rhel_subscription_password="$RHEL_SUBS_PASSWORD"

```
Now wait for the installation to complete. It may take around 40 mins to complete provisioning.

On successful install cluster details will be printed as shown below.
```
bastion_ip = 192.168.61.2
bastion_ssh_command = ssh root@192.168.61.2
bootstrap_ip = 192.168.61.3
cluster_id = test-cluster-9a4f
etc_hosts_entries =
192.168.61.2 api.test-cluster-9a4f.mydomain.com console-openshift-console.apps.test-cluster-9a4f.mydomain.com integrated-oauth-server-openshift-authentication.apps.test-cluster-9a4f.mydomain.com oauth-openshift.apps.test-cluster-9a4f.mydomain.com prometheus-k8s-openshift-monitoring.apps.test-cluster-9a4f.mydomain.com grafana-openshift-monitoring.apps.test-cluster-9a4f.mydomain.com example.apps.test-cluster-9a4f.mydomain.com

install_status = COMPLETED
master_ips = [
  "192.168.61.4",
  "192.168.61.5",
  "192.168.61.6",
]
oc_server_url = https://api.test-cluster-9a4f.mydomain.com:6443/
storageclass_name = nfs-storage-provisioner
web_console_url = https://console-openshift-console.apps.test-cluster-9a4f.mydomain.com
worker_ips = []
```

These details can be retrieved anytime by running the following command from the root folder of the code
```
$ terraform output
```
## Post Install

#### Delete Bootstrap Node

Once the deployment is completed successfully, you can safely delete the bootstrap node. This step is optional but recommended so as to free up the resources used.

1. Change the `count` value to 0 in `bootstrap` map variable and re-run the apply command. Eg: `bootstrap = { memory = 8192, vcpu = 4, count = 0 }`

2. Run command `terraform apply -var-file var.tfvars`


#### Create API and Ingress DNS Records

You can use one of the following options.

1. **Add entries to your DNS server**

    The general format is shown below:
    ```
    api.<cluster_id>.  IN  A  <bastion_ip>
    *.apps.<cluster_id>.  IN  A  <bastion_ip>
    ```
    You'll need `bastion_ip` and `cluster_id`. This is printed at the end of a successful install. Or you can retrieve it anytime by running `terraform output` from the install directory.
    For example, if `bastion_ip = 192.168.61.2` and `cluster_id = test-cluster-9a4f` then the following DNS records will need to be added.
    ```
    api.test-cluster-9a4f.  IN  A  192.168.61.2
    *.apps.test-cluster-9a4f.  IN  A  192.168.61.2
    ```

2. **Add entries to your client system `hosts` file**

    For Linux and Mac `hosts` file is located at `/etc/hosts` and for Windows it's located at `c:\Windows\System32\Drivers\etc\hosts`.

    The general format is shown below:
    ```
    <bastion_ip> api.<cluster_id>
    <bastion_ip> console-openshift-console.apps.<cluster_id>
    <bastion_ip> integrated-oauth-server-openshift-authentication.apps.<cluster_id>
    <bastion_ip> oauth-openshift.apps.<cluster_id>
    <bastion_ip> prometheus-k8s-openshift-monitoring.apps.<cluster_id>
    <bastion_ip> grafana-openshift-monitoring.apps.<cluster_id>
    <bastion_ip> <app name>.apps.<cluster_id>
    ```

    You'll need `etc_host_entries`. This is printed at the end of a successful install.
    Alternatively you can retrieve it anytime by running `terraform output` from the install directory.

    As an example, for the following `etc_hosts_entries`
    ```
    etc_hosts_entries =
    192.168.61.2 api.test-cluster-9a4f.mydomain.com console-openshift-console.apps.test-cluster-9a4f.mydomain.com integrated-oauth-server-openshift-authentication.apps.test-cluster-9a4f.mydomain.com oauth-openshift.apps.test-cluster-9a4f.mydomain.com prometheus-k8s-openshift-monitoring.apps.test-cluster-9a4f.mydomain.com grafana-openshift-monitoring.apps.test-cluster-9a4f.mydomain.com example.apps.test-cluster-9a4f.mydomain.com
    ```
    just add the following entry to the `hosts` file
    ```
    [existing entries in hosts file]

    192.168.61.2 api.test-cluster-9a4f.mydomain.com console-openshift-console.apps.test-cluster-9a4f.mydomain.com integrated-oauth-server-openshift-authentication.apps.test-cluster-9a4f.mydomain.com oauth-openshift.apps.test-cluster-9a4f.mydomain.com prometheus-k8s-openshift-monitoring.apps.test-cluster-9a4f.mydomain.com grafana-openshift-monitoring.apps.test-cluster-9a4f.mydomain.com example.apps.test-cluster-9a4f.mydomain.com
    ```

## Cluster Access

OpenShift login credentials are in the bastion host and the location will be printed at the end of a successful install.
Alternatively you can retrieve it anytime by running `terraform output` from the install directory.
```
[...]
bastion_ip = 192.168.61.2
bastion_ssh_command = ssh root@192.168.61.2
[...]
```
There are two files under `~/openstack-upi/auth`
- **kubeconfig**: can be used for CLI access
- **kubeadmin-password**: Password for `kubeadmin` user which can be used for CLI, UI access

>**Note**: Ensure you securely store the OpenShift cluster access credentials. If desired delete the access details from the bastion node after securely storing the same.

You can copy the access details to your local system
```
$ scp -r -i data/id_rsa root@1192.168.61.2:~/openstack-upi/auth/\* .
```

### Using CLI

OpenShift CLI `oc` can be downloaded from the following links. Use the one specific to your client system architecture.


- [Mac OSX](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/pre-release/openshift-client-mac.tar.gz)
- [Linux (x86_64)](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/pre-release/openshift-client-linux.tar.gz)
- [Linux (ppc64le)](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp-dev-preview/pre-release/openshift-client-linux.tar.gz)
- [Windows](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/pre-release/openshift-client-windows.zip)


Download the specific file, extract it and place the binary in a directory that is on your `PATH`
For more details check the following [link](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html)

The CLI login URL `oc_server_url` will be printed at the end of successful install.
Alternatively you can retrieve it anytime by running `terraform output` from the install directory.
```
[...]
oc_server_url = https://test-cluster-9a4f.mydomain.com:6443
[...]
```
In order to login the cluster you can use the `oc login <oc_server_url> -u kubeadmin -p <kubeadmin-password>`
Example:
```
$ oc login https://test-cluster-9a4f.mydomain.com:6443 -u kubeadmin -p $(cat kubeadmin-password)
```

You can also use the `kubeconfig` file
```
$ export KUBECONFIG=$(pwd)/kubeconfig
$ oc cluster-info
Kubernetes master is running at https://test-cluster-9a4f.mydomain.com:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'

$ oc get nodes
NAME       STATUS   ROLES    AGE   VERSION
master-0   Ready    master   13h   v1.18.3+b74c5ed
master-1   Ready    master   13h   v1.18.3+b74c5ed
master-2   Ready    master   13h   v1.18.3+b74c5ed
worker-0   Ready    worker   13h   v1.18.3+b74c5ed
worker-1   Ready    worker   13h   v1.18.3+b74c5ed
```

>**Note:** The OpenShift command-line client `oc` is already configured on the bastion node with kubeconfig placed at `~/.kube/config`.

### Using Web UI

The web console URL will be printed at the end of a successful install.
Alternatively you can retrieve it anytime by running `terraform output` from the install directory.
```
[...]
web_console_url = https://console-openshift-console.apps.test-cluster-9a4f.mydomain.com
[...]
```

Open this URL in your browser and login with user `kubeadmin` and password mentioned in the `kubeadmin-password` file.


## Clean up

To destroy after you are done using the cluster you can run command `terraform destroy -var-file var.tfvars` to make sure that all resources are properly cleaned up.
Do not manually clean up your environment unless both of the following are true:

1. You know what you are doing
2. Something went wrong with an automated deletion.
