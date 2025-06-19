## Kubernetes Storage Notes

Using Kubernetes StatefulSets, like for MongoDB, requires a [PersistentVolume Provisioner](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#limitations) 

### RKE2

RKE2 supports [Extra Control Plane Component Volume Mounts](https://docs.rke2.io/advanced#extra-control-plane-component-volume-mounts), but we may use a dedicated CSI Driver like
- [AWS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) for EBS volumes. See [Notes](./rke2/readme.md)
- [local-path-provisioner](https://github.com/rancher/local-path-provisioner) dynamically provisions volumes via either:
  - Kubernetes [hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)
  - Kubernetes [local](https://kubernetes.io/docs/concepts/storage/volumes/#local)
- [Longhorn](https://github.com/longhorn/longhorn) distributed storage

### K3S

Custom [Storage Options](https://docs.k3s.io/storage) include:
- Removal of volume plugins:
  - cephfs
  - fc
  - flocker
  - git_repo
  - glusterfs
  - portworx
  - quobyte
  - rbd
  - storageos
- Addition of Rancher's [Local Path Provisioner](https://github.com/rancher/local-path-provisioner)

Auto-Deploying Manifests (AddOns) manifests, like `local-path-provisioner`, are auto loaded from the directory `/var/lib/rancher/k3s/server/manifests`.

### K3D

K3D installs K3S and (at least K3D versions ~v5.1.0-v5.5.1) comes with [`rancher/local-path-provisioner:v0.0.24`](https://github.com/rancher/local-path-provisioner). The only difference from K3S seems to be that K3D uses the directory path `/var/lib/rancher/k3s/server/manifests/` on the `k3d-k3s-server` docker container to auto install Kubernetes manifests

> We could probably `ro` volume mount any additional manifests we need to load at k3d cluster creation
