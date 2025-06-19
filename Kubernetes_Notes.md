## Kubernetes Notes
```shell
# Check k8s environment variables (like KUBECONFIG) to determine kubectl configuration
env | grep -i kube
kubectl config view # View currently loaded configuration, like namespace context
# Get list of API versions supported by the cluster
kubectl api-versions
# Sometimes (due to kubectl and kubeconfig permissions) we have to force the namespace context change with sudo
sudo /var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml config set-context --current --namespace=kube-system
# (most) All resources
kubectl get all,cm,secret,ing -o wide  # Get most resources from current namespace context
kubectl get all,cm,secret,ing -A # Get most resources from all namespaces
# Namespaces
kubectl get namespaces  #Get namespaces
kubectl describe namespaces
kubectl create namespace foobar
kubectl delete namespace foobar
# Services
kubectl get services --all-namespaces -o wide
kubectl get services -n mynamespace -o wide
kubectl describe services
kubectl describe services -n mynamespace
# Pods
kubectl get pods --all-namespaces -o wide
kubectl get pods --namespace=kube-system
kubectl describe pods #Lower level description of the pods
## Deployments
kubectl get deployments --all-namespaces -o wide
kubectl describe deployments --all-namespaces #Lower level deployments description
kubectl describe deployments --namespace=kube-system calico-policy-controller
kubectl get configmap --all-namespaces
kubectl describe configmap calico-config -n kube-system
# Volumes
kubectl get pv  #Persistent volumes
kubectl get pvc -o wide #Persistent volume claims
kubectl describe pvc #Lower level description of the pvcs
# Roles, also supported "rolebindings"
kubectl get roles -o yaml
# Service Accounts
kubectl get serviceaccounts
kubectl get serviceaccounts --all-namespaces
# Secrets (current types: docker-registry; generic; and tls)
kubectl get secrets ingress-secret -o yaml #Secret Content Only output to screen when using output option (-o)
kubectl get secret ingress-secret -o go-template='{{index .data "tls.crt"}}' | base64 -d #Decode Base64 cert
kubectl delete secret tls ingress-secret #Easier to delete/recreate than update
kubectl create secret tls ingress-secret --key wildcard2.pem --cert wildcard2.cer
## TODO: It would be nice if we could re-order the output of the below commands 
##  like ('data' last), remove fields (creationTimestamp); add fields (type: Opaque). 
##  This should be possible with '-o go-template=' although it's fairly complicated
## Create a "truststore" secret manifest template containing 3 k/v pairs (the trust store password, jks, and p12 file)
cd /local/project-resources/pki/
kubectl create secret generic truststore --from-file=jks=./truststore.jks --from-file=p12=./truststore.p12 --from-file=pass=./trustPass.txt --dry-run=client -o yaml > ./my-secret-truststore.yml
## Add all files in the pki directory to a secret manifest, key is filename value is contents of file
cd /local/project-resources/pki
/var/lib/rancher/rke2/bin/kubectl create secret generic pkidir --from-file=./ --dry-run=client -o yaml > ./my-secret-pkidir.yml
## Add all files in the myapp directory to a secret manifest, key is filename value is contents of file
cd /local/project-resources/myapp/
/var/lib/rancher/rke2/bin/kubectl create secret generic myapp --from-file=./ --dry-run=client -o yaml > /home/ec2-user/git/notes/wip_compose_to_k8s/helm/templates/my-secret-myapp.yml #./my-secret-myapp.yml
# ConfigMaps
## Create a ConfigMap file containing all files in a directory. Only include parent dir, not children
cd /local/project-resources/config/
/var/lib/rancher/rke2/bin/kubectl create configmap configdir --from-file=./ --dry-run=client -o yaml 
## Adding a subdir, adds files but does not prepend subdir name so keys look like 'file.txt' and NOT 'subdir/file.txt`
/var/lib/rancher/rke2/bin/kubectl create configmap configdir --from-file=./ --from-file=./entities/ --dry-run=client -o yaml
### We can't add subdirectory files like this because a key cannot contain '/'
/var/lib/rancher/rke2/bin/kubectl create configmap configdir --from-file=./ \
--from-file=entities/entitySummaryProperties.json=./entities/entitySummaryProperties.json \
--from-file=entities/entityTypes.json=./entities/entityTypes.json \
--dry-run=client -o yaml
### So we will create a file per directory/subdirectory and mount them as subvolumes. Note: key must be lower alpha, '-', or '.'
/var/lib/rancher/rke2/bin/kubectl create configmap configdir --from-file=./ --dry-run=client -o yaml > /home/ec2-user/git/notes/wip_compose_to_k8s/helm/templates/configmap-configdir.yml
/var/lib/rancher/rke2/bin/kubectl create configmap configdir-entities --from-file=./entities/ --dry-run=client -o yaml > /home/ec2-user/git/notes/wip_compose_to_k8s/helm/templates/configmap-configdirEntities.yml
/var/lib/rancher/rke2/bin/kubectl create configmap configdir-nested-metadata --from-file=./nested-metadata/ --dry-run=client -o yaml > /home/ec2-user/git/notes/wip_compose_to_k8s/helm/templates/configmap-configdirNested-metadata.yml
/var/lib/rancher/rke2/bin/kubectl create configmap configdir-more-metadata --from-file=./more/metadata/ --dry-run=client -o yaml > /home/ec2-user/git/notes/wip_compose_to_k8s/helm/templates/configmap-configdirMoreMetadata.yml
# Metrics
kubectl top node NODE_NAME # Metrics for a node
kubectl top pod POD_NAME --containers  # Metrics for a pod and its containers
kubectl top pod POD_NAME --sort-by=cpu # Metrics for a pod and sort by 'cpu' or 'memory'
# Proxy/Port Forward
kubectl proxy # Creates a localhost proxy accessible in web browser
kubectl port-forward svc/my-service 5000 # listen on local 5000 and forward to 5000 on Service backend
kubectl port-forward svc/my-service 5000:my-service-port  # listen on local 5000 and forward to Service target port with name <my-service-port>
## Bash into a Pod
kubectl -it exec somepod-11aa22b1cc-aabcd /bin/bash
# Mark node as unschedulable/schedulable
kubectl cordon <node name>
#   Drain node in preparation for maintenance.
kubectl drain --ignore-daemonsets <node name>
kubectl uncordon <node name>
# Cluster info/dump
kubectl cluster-info
kubectl cluster-info dump --all-namespaces=true --output="yaml" --output-directory="D:\Users\someuser\Desktop\Temp\delete"
# Patch a PVC, changing the Reclaim Policy to 'Delete'
kubectl patch pv/pvc-1111111c-1111-111a-a111-1a111111a111 -p "{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Delete\"}}"
```

## Operator
Used for Stateful apps like databases, uses control loop mechanism.  
Uses CRD (custom K8S component)

## Kubernetes Models
As of `2021`, there was [3 main models](https://kubernetes.io/blog/2021/04/15/three-tenancy-models-for-kubernetes/)

- **namespaces as a service**: tenants share a cluster
  - tenants share cluster-wide resources
  - requires proper security configurations, each namespace must contain:
    - role bindings: for controlling access to the namespace
    - network policies: to prevent network traffic across tenants
    - resource quotas: to limit usage and ensure fairness across tenants
- **clusters as a service**: tenant gets own cluster
  - allows different versions of cluster-wide resources
  - provides full isolation of the Kubernetes control plane
- **control planes as a service (Virtual Cluster)**: tenant gets dedicated Kubernetes control plane but shares worker node resources
  - share single Kubernetes cluster resources
  - let tenants manage their own cluster-wide resources
  - sharing worker node resources increases resource efficiencies
    - exposes cross tenant security and isolation concerns that exist for shared clusters

## Kubernetes Debugging

### Logs
Commands to run when Debugging Kubernetes issues
```bash
## Initially, check the Deployment
kubectl describe deployment/nginx --namespace foobar
kubectl get deployment/nginx --namespace foobar -o wide
kubectl get deployment/nginx --namespace foobar -o json # Output more fields like "status"
## Check the Pod Logs
kubectl get pods --namespace foobar # Outputs pod name nginx-1111111111-a1aa1
kubectl get pod nginx-1111111111-a1aa1 -o wide
kubectl describe pod nginx-1111111111-a1aa1 # Return the best debugging results
kubectl logs nginx-1111111111-a1aa1 --follow=true --all-containers
### Filter initContainer messages
kubectl get pods service-2222222222-a2aa2 --namespace foobar --template '{{.status.initContainerStatuses}}'
### Get initContainer messages with command 'kubectl logs <podname> -c <initcontainerName>'
kubectl logs service-3333333333-a3aa3 -c init-wait-seconds
## Lastly, check the event log
kubectl get events --sort-by=.metadata.creationTimestamp
## Check Deployment Logs, use tail to display X lines of end
/var/lib/rancher/rke2/data/v1.24.8-rke2r1-59ea8d19b74f/bin/kubectl --kubeconfig ~/rke2.yaml logs --tail=20 deployment/gitlab-runner
```

### Hung `kubectl` commands
Fix a hung physical volume deletion by adding a patch to finalizers
```shell
kubectl patch pv/pvc-a1a1aaa1-111a-111a-1aa1-aa111a11a11a -p '{"metadata":{"finalizers":[]}}' --type=merge
```

### Hung namespace delete
Namespace delete is usually due to a finalizer not finishing. Force deletion description below isn't great (may leave orphaned resources maybe CRDs) but YMMV
```bash
# Check the namespace
kubectl describe namespace opensearch
# Remove the finalizer
kubectl edit namespace 
```

## Networking
### Types
- `ClusterIP` - Default, only routes traffic within cluster
  - Can be exposed via `Ingress` or `Gateway API`
- `NodePort` - Extension of `ClusterIP`, opens ports from all Kubernetes Nodes (Instance) to the Service
- `LoadBalancer` - Exposes Service externally to Cloud Provider's Load Balancer
- `ExternalName` - Maps Service to external DNS name like `foo.com` by returning a CNAME record, requires kube-dns 1.7+

### Port Types
- `containerPort` : Seems to be mostly documentation/informational. May be specified used in a `Pod` or `Deployment`. Analogous to the Dockerfile `EXPOSE` which doesn't publish and must be published via the `-p` flag on `docker run`
- `port` : Service exposed port on the cluster. Other cluster pods can communicate with this server on this port
- `targetPort` : Port on the pod the service will send traffic to (K8S will default to same value as `port`)
- `nodePort` : Exposes service externally on the Node's IP, typically ports range `30000-32767`

Additionally, for `protocol` the default is `TCP`, other values can be `UDP` or `SCTP`

Port definitions in Pods have names, and you can reference these names in the `targetPort` attribute of a Service. Example:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: proxy
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
      - containerPort: 80
        name: http-web-svc
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    targetPort: http-web-svc
```

## Service

Kubernetes built-in DNS service allows services to be discovered by their DNS name. Each service is assigned a DNS name that is based on its name and namespace. The DNS name for a service is in the following format:
`<service-name>.<namespace>.svc.cluster.local`

## Probes and conditional service ordering
There's quite a variety of option such as
- `Liveness Probe` - determine when to restart a (hung) container. Example: do a `touch` and `cat` of a file, and if it continually fails, restart container
- `Readiness Probe` - determine when to start sending traffic. Example: a database loads a large amount of data on startup and cannot service requests immediately
- `Startup Probe` - determine when a container application has started. Example: a slow legacy application takes 4 minutes to start

Example of using a Liveness and Startup Probe using a named port. Startup probe waits up to 300 seconds after container startup to restart.
```yaml
ports:
- name: liveness-port
  containerPort: 8080
  hostPort: 8080

livenessProbe:
  httpGet:
    path: /healthz
    port: liveness-port
  failureThreshold: 1
  periodSeconds: 10

startupProbe:
  httpGet:
    path: /healthz
    port: liveness-port
  failureThreshold: 30
  periodSeconds: 10
```

Additionally `Init Containers` are a possibility but seem to be scoped more narrowly to Pods and not Deployments and Probes above seem to be better architecture.

## Labels and Selectors

- `metadata.name` : unique name for the Kubernetes resource within its namespace. Used to identify and reference the resource
- `metadata.labels` : provide additional metadata, used for organizing and selecting subsets of resources based on specific criteria, helpful for managing and categorizing resources
- `spec.selector.matchLabels` : used in controllers (like Deployments or ReplicaSets) to select a set of Pods that the controller will manage. Specifies the labels that must match for a Pod to be considered part of the controlled set
- `spec.template.metadata.labels` : used within controllers to set the labels for the Pods that the controller creates. These labels are used to match the selector, ensuring that the created Pods are managed by the controller

### Recommended labels
All of these Recommended labels are Type `string`

| Key                            | Description                                                                    | Example        |
| ------------------------------ | ------------------------------------------------------------------------------ | -------------- |
| `app.kubernetes.io/name`       | Name of the application                                                        | `mysql`        |
| `app.kubernetes.io/instance`   | Unique name identifying the instance of an application                         | `mysql-abcxzy` |
| `app.kubernetes.io/version`    | Current version of the application (Common to use SemVer, revision hash, etc.) | `5.7.21`       |
| `app.kubernetes.io/component`  | Component within the architecture                                              | `database`     |
| `app.kubernetes.io/part-of`    | Name of a higher level application this one is part of                         | `wordpress`    |
| `app.kubernetes.io/managed-by` | Tool being used to manage the operation of an application                      | `helm`         |

## Helm Notes
Helm comments are best whitespaced in the format `{{- /* Comment Here */}}`
```shell
helm repo list
helm repo add argo https://argoproj.github.io/argo-helm
# ~/.config/helm/repositories.yaml ; ~/.cache/helm/repository/argo-charts.txt ; ~/.cache/helm/repository/argo-index.yaml
#helm repo add dandydev https://dandydeveloper.github.io/charts # Creates .cache/helm/repository/dandydev-charts.txt
helm repo update
helm search repo redis
# Show all versions
helm search repo redis --versions
# Lint a local chart, will find basic syntax errors
helm lint .
# helm template <CHART_NAME> <REPO_NAME>/<PATH_TO_CHART> --values=<FILE_NAME>
# Render a local helm chart to a Kubernetes manifest
helm template . # --output-dir ./output/
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm template . --dependency-update --output-dir ./output/
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm template . --dependency-update --output-dir ./output/new/
## Render using an override file
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm template . -f ./examples/override.yml --dependency-update --output-dir ./output/new/
# List all Helm installs in all namespaces
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml list --all --all-namespaces
# Helm install dry run debug (validates server side) from a local chart
cd /home/ec2-user/git/notes/wip_compose_to_k8s/helm/
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml install --namespace "myns" "myapp" ./ --dry-run --debug
## Helm install dry run debug using an override file
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml install --namespace "myns" "myapp" -f ./examples/override.yml ./ --dry-run --debug
# Helm re-install/upgrade a chart
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml upgrade --install --namespace "myns" "myapp" ./ #--force
## Helm re-install/upgrade a chart using an override file
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml upgrade --install --namespace "myns" "myapp" -f ./examples/override.yml ./
# Helm uninstall a chart
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm uninstall --namespace "myns" "myapp"
# Helm plugin list
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm plugin list
# Add Helm Diff plugin
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm plugin install https://github.com/databus23/helm-diff
# Run Helm Diff plugin
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml diff upgrade --namespace "myns" "myapp" ./
## Run Helm Diff plugin using an override file
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml diff upgrade --namespace "myns" "myapp" -f ./examples/override.yml ./
# Show Helm History
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml history "myapp"
# Simulate Helm Rollback to a previous REVISION
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml rollback "myapp" 1 --dry-run
# Helm Diff Revisions
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml diff revision "myapp" 1 2
# Helm Diff Rollback to a specified REVISION
/home/ec2-user/.local/state/vs-kubernetes/tools/helm/linux-amd64/helm --kubeconfig ~/rke2.yaml diff rollback "myapp" 1
# Helm package a Chart as a zip that can be installed on a cluster
helm package -d ./output/  # --app-version "0.0.1"
```

## Velero WIP

```bash
mkdir ~/velero/
cd ~/velero/
wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.0/velero-v1.13.0-linux-amd64.tar.gz
tar -xvf velero-v1.13.0-linux-amd64.tar.gz
cd ~/velero/velero-v1.13.0-linux-amd64
./velero --kubeconfig ~/rke2.yaml -n myns get backup-locations
./velero --kubeconfig ~/rke2.yaml -n myns get schedules

./velero --kubeconfig ~/rke2.yaml -n myns backup create my-backup --include-resources pvc,pv
./velero --kubeconfig ~/rke2.yaml -n myns backup describe my-backup

#./velero --kubeconfig "~/rke2.yaml" backup create my-backup --include-resources pvc,pv --include-namespaces myns
#velero backup create my-backup --include-resources pvcs,pvs --include-namespaces myns
```

## K9S

```bash
mkdir ~/k9s/
cd ~/k9s/
#wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm
sudo yum localinstall k9s_linux_amd64.rpm
#wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz
k9s --kubeconfig ~/rke2.yaml
```
