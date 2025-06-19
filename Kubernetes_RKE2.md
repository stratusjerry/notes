## Presumptions

* Running on RedHat 8
  * Defaults to running NetworkManager
    * We will install the RKE2 mentioned calico/flannel [Network Manager fix](https://docs.rke2.io/known_issues/#networkmanager)
    * We don't have to fix `nm-cloud-setup.service` and `nm-cloud-setup.timer` mentioned in the article above as a newer [Network manager version](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/740#note_1253727) fixes the issue
* We will install the selinux .rpm and tarball install, as RKE2 seems to have [dropped support](https://github.com/rancher/rke2/blob/master/docs/adrs/002-rke2-rpm-support.md) for any new rpm server installs
* Running newest RKE2 1.25.x (1.25.5+rke2r1) as K8S is supported till [2023/10/27](https://kubernetes.io/releases/#release-v1-25)

## RHEL 8 Config
After Install
1. Test Access:
   ```bash
   sudo su
   journalctl -fu rke2-server
   /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods --all-namespaces
   ```
2. Setup Vscode Access:
   1. From the Remote box
      ```bash
      sudo cp /etc/rancher/rke2/rke2.yaml /home/ec2-user/
      sudo chown ec2-user /home/ec2-user/rke2.yaml
      ```
   2. Vscode open Remote session
      1. Install Kubernetes extension on Remote
         > Note: In Vscode you may have to go to `View` -> `Secondary Sidebar` to see the Kubernetes Windows
      2. Under remote settings set **"vscode-kubernetes.kubectl-path": "/var/lib/rancher/rke2/bin/kubectl"**
         > This might fail, in which case installing the prompted vscode kubernetes tools worked
      3. From the Kubernetes Window -> `Cluster` -> `...` -> `Set KubeConfig` ; Add "/home/ec2-user/rke2.yaml"
      > Test as ec2-user `/var/lib/rancher/rke2/bin/kubectl --kubeconfig ~/rke2.yaml get pods --all-namespaces`

### Other Notes
[AWS Custom Regions install](https://github.com/rancher/rke2-docs/blob/main/docs/advanced.md#installation-on-classified-aws-regions-or-networks-with-custom-aws-api-endpoints)

Kubernetes manifests found in `/var/lib/rancher/rke2/server/manifests` will automatically be deployed to RKE2 in a manner similar to `kubectl apply`. Manifests deployed in this manner are managed as AddOn custom resources, and can be viewed by running `kubectl get addon -A`. You will find AddOns for packaged components such as CoreDNS, Local-Storage, Nginx-Ingress, etc. AddOns are created automatically by the deploy controller, and are named based on their filename in the manifests directory.

## HELM
VScode installed helm run like: `~/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml list --all-namespaces`

Six different ways you can express the chart you want to install:
1. By chart reference: `helm install mymaria example/mariadb`
2. By path to a packaged chart: `helm install mynginx ./nginx-1.2.3.tgz`
3. By path to an unpacked chart directory: `helm install mynginx ./nginx`
4. By absolute URL: `helm install mynginx https://example.com/charts/nginx-1.2.3.tgz`
5. By chart reference and repo url: `helm install --repo https://example.com/charts/ mynginx nginx`
6. By OCI registries: `helm install mynginx --version 1.2.3 oci://example.com/charts/nginx`

To modify a helm chart/repo best option seems to be [Kustomize](https://kubectl.docs.kubernetes.io/) which is supported natively with the `kubectl kustomize` command

## RKE2 Defaults

| Description                                   |    Path                             |
|-                                              |-                                    |
| Default configuration file                    | `/etc/rancher/rke2/config.yaml`     |
| Default private registries configuration file | `/etc/rancher/rke2/registries.yaml` |
| Default kubeconfig file                       | `/etc/rancher/rke2/rke2.yaml`       |
| Default State Directory                       | `/var/lib/rancher/rke2/`            |

### Default token
First node RKE2 install places a token under `/var/lib/rancher/rke2/server/node-token` which is used in subsequent rke2 server node joins under the rke2 config file

In researching how to pre-create this (as having the token in the config file doesn't seem to work on the first node), [this comment](https://github.com/rancher/rke2/discussions/4316#discussioncomment-6093337) mentions that K3S cert/token process is similar to RKE2. K3S [server token](https://docs.k3s.io/cli/token#server) documentation mentions __*Unless custom CA certificates are in use, only the short (password-only) token format can be used when starting the first server in the cluster. This is because the cluster CA hash cannot be known until after the server has generated the self-signed cluster CA certificates*__. 

The K3S [Using Custom CA's documentation](https://docs.k3s.io/cli/certificate#using-custom-ca-certificates) may be useful in pre-creating tokens, we may additionally pre-create (CA, keys, certs) files that have an expiry time longer than the default 365 days.

## RKE2 Commands

### Top Level `rke2` commands

| Command         | Description                                      |
|-                |-                                                 |
| server          | Run management server                            |
| agent           | Run node agent                                   |
| etcd-snapshot   | Trigger an immediate etcd snapshot               |
| certificate     | Certificates management                          |
| secrets-encrypt | Control secrets encryption and keys rotation     |
| token           | Manage bootstrap tokens                          |
| help, h         | Shows a list of commands or help for one command |

### `rke2 server` commands
Relevant `rke2 server` options from [github](https://github.com/rancher/rke2-docs/blob/main/docs/reference/server_config.md)
| Option | Component | Description |
|-       |-          |-            |
| --config FILE, -c FILE          | config     | Load configuration from FILE (default: "/etc/rancher/rke2/config.yaml") [$RKE2_CONFIG_FILE] |
| --debug                         | logging    | Turn on debug logs [$RKE2_DEBUG] |
| --bind-address value            | listener   | rke2 bind address (default: 0.0.0.0)                                                                        |
| --advertise-address value       | listener   | IPv4 address that apiserver uses to advertise to members of the cluster (default: node-external-ip/node-ip) |
| --tls-san value                 | listener   | Add additional hostnames or IPv4/IPv6 addresses as Subject Alternative Names on the server TLS cert         |
| --data-dir value, -d value      | data       | Folder to hold state (default: "/var/lib/rancher/rke2") |
| --cluster-cidr value            | networking | IPv4/IPv6 network CIDRs to use for pod IPs (default: 10.42.0.0/16)                              |
| --service-cidr value            | networking | IPv4/IPv6 network CIDRs to use for service IPs (default: 10.43.0.0/16)                          |
| --service-node-port-range value | networking | Port range to reserve for services with NodePort visibility (default: "30000-32767")            |
| --cluster-dns value             | networking | IPv4 Cluster IP for coredns service. Should be in your service-cidr range (default: 10.43.0.10) |
| --cluster-domain value          | networking | Cluster Domain (default: "cluster.local")                                                       |
| --token value, -t value         | cluster | Shared secret used to join a server or agent to a cluster [$RKE2_TOKEN]        |
| --token-file value              | cluster | File containing the cluster-secret/token [$RKE2_TOKEN_FILE]                    |
| --cluster-reset                 | cluster | Forget all peers and become sole member of a new cluster [$RKE2_CLUSTER_RESET] |
| --cluster-reset-restore-path value | db | Path to snapshot file to be restored |
| --node-name value                  | agent/node | Node name [$RKE2_NODE_NAME] |
| --private-registry value           | agent/runtime | Private registry configuration file (default: "/etc/rancher/rke2/registries.yaml") |
| --system-default-registry value    | agent/runtime | Private registry to be used for all system images [$RKE2_SYSTEM_DEFAULT_REGISTRY]  |
| --selinux                          | agent/node | Enable SELinux in containerd [$RKE2_SELINUX] |
| --cni value                        | networking | CNI Plugins to deploy, one of none, calico, canal, cilium; optionally with multus as the first value to enable the multus meta-plugin (default: canal) [$RKE2_CNI] |
| --kube-apiserver-image value           | image | Override image to use for kube-apiserver [$RKE2_KUBE_APISERVER_IMAGE]                               |
| --kube-controller-manager-image value  | image | Override image to use for kube-controller-manager [$RKE2_KUBE_CONTROLLER_MANAGER_IMAGE]             |
| --cloud-controller-manager-image value | image | Override image to use for cloud-controller-manager [$RKE2_CLOUD_CONTROLLER_MANAGER_IMAGE]           |
| --kube-proxy-image value               | image | Override image to use for kube-proxy [$RKE2_KUBE_PROXY_IMAGE]                                       |
| --kube-scheduler-image value           | image | Override image to use for kube-scheduler [$RKE2_KUBE_SCHEDULER_IMAGE]                               |
| --pause-image value                    | image | Override image to use for pause [$RKE2_PAUSE_IMAGE]                                                 |
| --runtime-image value                  | image | Override image to use for runtime binaries (containerd, kubectl, crictl, etc) [$RKE2_RUNTIME_IMAGE] |
| --etcd-image value                     | image | Override image to use for etcd [$RKE2_ETCD_IMAGE]                                                   |

### `rke2 certificate` commands
 CA certificates and keys found in `/var/lib/rancher/rke2/server/tls` on the first rke2 server startup will bypass automatic CA cert generation. [This](https://github.com/k3s-io/k3s/blob/master/contrib/util/generate-custom-ca-certs.sh) k3s script (also saved at [./generate-custom-ca-certs.sh](./generate-custom-ca-certs.sh) ) is used as an example of how to generate a CA. The following files are required:
* `server-ca.crt`
* `server-ca.key`
* `client-ca.crt`
* `client-ca.key`
* `request-header-ca.crt`
* `request-header-ca.key`  
* `etcd/peer-ca.crt`  
* `etcd/peer-ca.key`
* `etcd/server-ca.crt`
* `etcd/server-ca.key`  
  *// note: This is the private key used to sign service-account tokens. It does not have a corresponding certificate.*
* `service.key`

Relevant `rke2 certificate` options from [github](https://github.com/rancher/rke2-docs/blob/main/docs/security/certificates.md). Note 
| Option | Description |
|-       |-            |
| `rotate --service` | List of services to rotate certificates for. Options include (admin, api-server, controller-manager, scheduler, rke2-controller, rke2-server, cloud-controller, etcd, auth-proxy, kubelet, kube-proxy) |
| `rotate-ca`        | Write updated rke2 CA certificates to the datastore |

```bash
# Stop RKE2, rotate certs, and start RKE2
systemctl stop rke2
rke2 certificate rotate
systemctl start rke2
```

### `rke2 token` commands

| Option     | Description                                                              |
|-           |-                                                                         |
| `create`   | Create bootstrap tokens on the server                                    |
| `delete`   | Delete bootstrap tokens on the server                                    |
| `generate` | Generate and print a bootstrap token, but do not create it on the server |
| `list`     | List bootstrap tokens on the server                                      |
| `rotate`   | Rotate original server token with a new bootstrap token                  |

## Debugging
Debug logs with command `tail -n +0 /var/lib/rancher/rke2/agent/containerd/containerd.log /var/log/containers/*`. The `/var/lib/rancher/rke2/server/token` file contents is `K10`, then the result of `sha256sum /var/lib/rancher/rke2/server/tls/server-ca.crt`, then `::server:`; and finally 

Start rke2 server in debug mode
```bash
/usr/local/bin/rke2 server --debug
```

Dump service logs
```bash
journalctl -u rke2-server.service --no-pager -n 1000
# Continuously watch logs (like 'tail -f')
journalctl -u rke2-server.service -f
```

Checking etcd status, taken from https://gist.github.com/superseb/3b78f47989e0dbc1295486c186e944bf#on-the-etcd-host-itself
```bash
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
etcdcontainer=$(/var/lib/rancher/rke2/bin/crictl ps --label io.kubernetes.container.name=etcd --quiet)
# sudo /var/lib/rancher/rke2/bin/crictl --config /var/lib/rancher/rke2/agent/etc/crictl.yaml ps
/var/lib/rancher/rke2/bin/crictl exec $etcdcontainer sh -c "ETCDCTL_ENDPOINTS='<https://127.0.0.1:2379>' ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt' ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt' ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key' ETCDCTL_API=3 etcdctl endpoint status --cluster --write-out=table"
```

TODO: command above fails to find `sh` (or `ash`) in `index.docker.io/rancher/hardened-etcd:v3.5.9-k3s1-build20240418`. Provenance:
1. First Stage seems to be: https://github.com/rancher/image-build-base/blob/master/Dockerfile
2. Second Stage seems to be: https://github.com/rancher/image-build-etcd/blob/master/Dockerfile

#### Exec into a pod as root
```bash
# Got the pod (curl-test) ID to root into (assumes it's already running)
kubectl get pod curl-test -n mynamespace -o jsonpath="{.status.containerStatuses[].containerID}" | sed 's/.*\/\///'
# Use runc to Exec in as root
sudo /var/lib/rancher/rke2/bin/runc --root /run/containerd/runc/k8s.io/ exec -t -u 0 000aa0aaaab0aaaa0a00000000000000a0aaaa000aa0a0a00a00aa0aa000aa0aa sh
```

#### Kubernetes nodes with crictl
```bash
sudo su
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
# List all running containers
/var/lib/rancher/rke2/bin/crictl ps -a
# List images
/var/lib/rancher/rke2/bin/crictl images
# Remove unused images, this may not be as safe (cronjobs that aren't currently running), deleted:
#   rancher/rke2-runtime:v1.28.8-rke2r1
#   rancher/hardened-dns-node-cache:1.22.28-build20240125
#   rancher/hardened-k8s-metrics-server:v0.6.3-build20231009
#   rancher/klipper-lb:v0.4.7
#   rancher/mirrored-ingress-nginx-kube-webhook-certgen:v20230312-helm-chart-4.5.2-28-g66a760794
#   rancher/mirrored-pause:3.6
#   rancher/mirrored-sig-storage-snapshot-controller:v6.2.1
#   rancher/mirrored-sig-storage-snapshot-validation-webhook:v6.2.2
/var/lib/rancher/rke2/bin/crictl rmi --prune 
```

### Kubernetes nodes with ctr

```bash
sudo su
# List containers
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io container ls
# List images
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images ls
# Pull an image
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io image pull docker.io/library/hello-world:latest
# Pull from Artifactory
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io image pull artifactory.tld/library/hello-world:latest
# Export container as tar
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io image export hello-world-latest.tar "artifactory.tld/library/hello-world:latest"
# Prune images
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images prune --all
# Import a container from tar format
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images import hello-world-latest.tar
# Specifying a "--platform linux/amd64" may fix import issues, but including all platforms worked for a pull/export/import
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io image pull artifactory.tld/library/hello-world:latest --all-platforms
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io image export hello-world-latest.tar "artifactory.tld/library/hello-world:latest" --all-platforms
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images import hello-world-latest.tar
```

### Uninstaller
From https://www.suse.com/support/kb/doc/?id=000020162
```bash
curl -sLO https://github.com/rancherlabs/support-tools/raw/master/extended-rancher-2-cleanup/extended-cleanup-rancher2.sh
```

## Random Notes

### Generating list of container images
Download from github url like https://github.com/rancher/rke2/releases/download/v1.28.8%2Brke2r1/rke2-images.linux-amd64.txt OR 
Extract container image versions:
```bash
tar xzvf rke2-images.linux-amd64.tar.gz --wildcards --no-anchored "manifest.json"
# use jq to get rke2 container tags
jq -r '.[] | .RepoTags[]' ${localdir}${ver}/manifest.json > ${localdir}${ver}/rke2-images.linux-amd64-manifest.txt
```

### Older image notes
Mirror RKE2 `v1.25.5` x64 images, taken from https://github.com/rancher/rke2/releases/download/v1.25.5%2Brke2r2/rke2-images.linux-amd64.txt
We should not need the [all images text file](https://github.com/rancher/rke2/releases/download/v1.25.5%2Brke2r2/rke2-images-all.linux-amd64.txt)
```bash
export images="
rancher/rke2-runtime:v1.25.5-rke2r2
rancher/hardened-kubernetes:v1.25.5-rke2r2-build20230104
rancher/hardened-coredns:v1.9.3-build20221011
rancher/hardened-cluster-autoscaler:v1.8.5-build20221011
rancher/hardened-dns-node-cache:1.21.2-build20221011
rancher/hardened-etcd:v3.5.4-k3s1-build20221011
rancher/hardened-k8s-metrics-server:v0.6.2-build20221202
rancher/klipper-helm:v0.7.4-build20221121
rancher/klipper-lb:v0.4.0
rancher/pause:3.6
rancher/mirrored-ingress-nginx-kube-webhook-certgen:v1.1.1
rancher/nginx-ingress-controller:nginx-1.4.1-hardened2
rancher/rke2-cloud-provider:v1.25.3-build20221017
rancher/hardened-calico:v3.24.5-build20221201
rancher/hardened-flannel:v0.20.2-build20221201
"
export tagprefix="artifacory.tld/myusername/"

counter=0
for i in $images
do
  ((counter++))
  echo "Docker image: ${i} Count: ${counter}"
  docker pull ${i}
  docker tag ${i} "${tagprefix}${i}"
  docker push "${tagprefix}${i}"
done
```
