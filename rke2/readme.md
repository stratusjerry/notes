# RKE2 Notes

## AWS EBS Persistent Storage via IAM Role

After RKE2 is installed, add and configure the AWS EBS CSI Driver to use the IAM Role for provisioning EBS volumes
```bash
cd ~
# Copy the RKE2 config to users home directory
sudo cp /etc/rancher/rke2/rke2.yaml ~
sudo chown ec2-user ~/rke2.yaml
# Add the Helm binary
sudo yum install -y wget
wget https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz
tar -zxvf helm-v3.11.1-linux-amd64.tar.gz --strip-components=1
chmod +x ~/helm
# Add the AWS EBS CSI Helm Repo
~/helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
~/helm repo update
```
Edit the [csi-override-values.yaml](./csi-override-values.yaml) file to use IAM Role name attached to the RKE2 EC2 instance and install the AWS EBS CSI Helm Chart with the override file
```bash
~/helm --kubeconfig ~/rke2.yaml upgrade --install aws-ebs-csi-driver --namespace kube-system aws-ebs-csi-driver/aws-ebs-csi-driver --values ~/csi-override-values.yaml # --dry-run
# Check the deployment with kubectl
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml get pod -n kube-system -l "app.kubernetes.io/name=aws-ebs-csi-driver,app.kubernetes.io/instance=aws-ebs-csi-driver"
```
Test that RKE2 can use IAM to create EBS volumes by creating a Storage Class and Physical Volume Claim
> Note: the RKE2 instance must be in the same AZ specified in the storage class!
```bash
# Create a new namespace 'monitoring'
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml create namespace monitoring
# Create Storage Class
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml apply -f ~/storage-class.yaml -n monitoring
# Verify Storage Class
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml get sc/aws-ebs-k8 -o wide
# Create PVC, this will create a PhysicalVolume EBS volume
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml apply -f ~/pvc.yaml -n monitoring
# Verify Physical Volume
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml get persistentvolume -n monitoring -o wide
# Attempt to create a pod using PVC
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml apply -f ~/pod.yaml -n monitoring
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml get pod/app --namespace monitoring -o wide
# If any errors occur, change output to json to debug
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml get pod/app --namespace monitoring -o json
```
You can exec into the Pod and view the physical volume contents
```bash
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml exec pod/app --stdin --tty -- /bin/bash
ls -alh /data
cat /data/out.txt
exit
```
Now destroy the samples we created
> **Important:** since [storage-class](./storage-class.yaml) is set to `reclaimPolicy: Retain`, the EBS volume must manually be deleted from AWS after the steps below
```bash
# Remove the Pod
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml delete -f ~/pod.yaml -n monitoring
# Remove the Physical Volume
#/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml patch pv/pvc-7380906c-6888-486c-b757-4c975321e667 -p "{\"spec\":{\"persistentVolumeReclaimPolicy\":\"Delete\"}}"
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml delete -f ~/pvc.yaml -n monitoring
# Remove the storage class
/var/lib/rancher/rke2/data/v1.25.5-rke2r2-a9acdcb2f08a/bin/kubectl --kubeconfig ~/rke2.yaml delete -f ~/storage-class.yaml -n monitoring
```
