## Docker Cheatsheet
```bash
docker ps -a #Same output as 'docker container ls -a'
docker container ls -a #List containers
docker build . #Build a container from a Dockerfile
docker images -a --digests #Show images with digests
docker image save --output etcd.tar rancher/hardened-etcd:v3.5.9-k3s1-build20240418 #Save a docker container as a tarball
docker system df -v #Show docker disk usage
docker cp <containerID>:/foo.txt /tmp/ #Copy file from container (id) to local
docker cp /tmp/foo.txt <containerID>:/foo.txt #Copy file from local to container (id)
## Debugging
sudo dockerd --debug #Run docker in debug mode to diagnose why daemon cannot start
docker logs --tail 1000 -f <containerID> #Check docker logs
docker exec -it <containerID> bash #Get a bash shell in a running container
docker run -it --entrypoint "/bin/sh" kaniko:latest #Thin image without bash, override entrypoint
docker run --publish 3389:3389 -it ghcr.io/linuxserver/baseimage-rdesktop:alpine #Run a container opening mapping ports on host to container
# Run a container, mounting SSH Auth socket and working directory in as volumes
docker run -it --name my-test -e RUNNER=${USER} -e SSH_AUTH_SOCK=/ssh-agent -v ${SSH_AUTH_SOCK}:/ssh-agent:ro -v `pwd`:/apps "dockerrepo.tld/tools:1.0" bash
getent group docker #Get members of group docker
gpasswd -a centos docker #Add centos user to the docker group
gpasswd -d centos docker #Remove centos user from the docker group
sudo usermod -a -G docker centos #Add centos user to the docker group
sudo usermod -a -G docker "ec2-user" #Add ec2-user user to the docker group
sudo usermod -G docker centos #Remove the centos user from the docker group
# TODO: add notes on debugging options related to overriding entrypoint, privileged, and using busybox on thin containers
## Safe docker cleanup
docker volume prune #Remove unused local volumes
docker image prune #Remove unused images
## Extra cleanup
docker system prune --all --volumes #Remove unused containers, networks, images (both dangling and unreferenced). Extra flags --all : Remove all unused images not just dangling ones AND --volumes: Prune volumes
# Run the mongodb container
docker run --rm -it --entrypoint bash -p 27017:27017/tcp --name mongodb dockerrepo.tld/mongo@sha256:1111111111111111111111111111111111111111111111111111111111111111
```

## Compose Cheatsheet
```shell
docker compose config # Render a compose file (shows variable substitution, YAML anchors)
docker compose rm # Removes stopped service containers
docker compose stop # Stops running containers without removing them. Can be started again with docker compose start
docker compose top # Display the running processes
# Bring up and Recreate all OR a single container
docker compose up -d --force-recreate
docker compose up -d --force-recreate prom
# Make a change to docker-compose.yml like adding a port or modifying Healthcheck (Note: restart does NOT work to get new value)
docker compose stop frontend
docker compose up -d frontend # May have to add --force-recreate flag
#docker compose -f docker-compose-data.yml restart mongodb
docker compose -f docker-compose-data.yml stop mongodb
docker compose -f docker-compose-data.yml up -d mongodb
# Remove docker compose containers, network, and volumes but NOT images
docker compose down -v
# Terminate compose stack containers and delete the images used to create the containers
docker compose -f docker-compose.yml down --rmi all
# Terminate compose stack containers; delete the images used to create the containers; as well as volumes
docker compose -f docker-compose.yml down --rmi all --volumes
#docker compose -f docker-compose-data.yml down --rmi all --volumes
# Download the container images locally
docker compose -f docker-compose.yml pull
# Download a specific service container locally
docker compose -f docker-compose.yml pull frontend
```

Compose Arguments
<table>
<tr><th>Command</th><th>Argument</th><th>Description</th></tr>
<tr><td rowspan="4">docker compose down</td>
<td></td><td>By default, the only things removed are:
<ul>
<li>Containers for services defined in the Compose file</li>
<li>Networks defined in the networks section of the Compose file</li>
<li>The default network, if one is used</li>
</ul></td></tr>
<tr><td>--remove-orphans</td><td>
Remove containers for services not defined in the Compose file
</td></tr>
<tr><td>--rmi</td><td>Remove images used by services. "local" remove only images that don't have <br>
a custom tag ("local"|"all")</td>
<tr><td>--volumes , -v</td><td>Remove named volumes declared in the volumes section of the Compose <br>
file and anonymous volumes attached to containers</td></tr>
<tr><td rowspan="4">docker compose rm</td>
<td></td><td>By default, anonymous volumes attached to containers are not removed; can override <br>
this with '-v'. Default option also removes one-off containers created by "docker compose run"</td></tr>
<tr><td>--force , -f</td><td>Don't ask to confirm removal</td></tr>
<tr><td>--stop , -s</td><td>Stop the containers, if required, before removing</td></tr>
<tr><td>--volumes , -v</td><td>Remove any anonymous volumes attached to containers</td>
</tr>
<tr><td rowspan="7">docker compose up</td>
<td>--build</td><td>Build images before starting containers</td></tr>
<tr><td>--detach , -d</td><td>Detached mode: Run containers in the background</td></tr>
<tr><td>--force-recreate</td><td>Recreate containers even if their configuration and image haven't changed.</td></tr>
<tr><td>--no-build</td><td>Don't build an image, even if it's missing.</td></tr>
<tr><td>--no-deps</td><td>Don't start linked services.</td></tr>
<tr><td>--no-start</td><td>Don't start the services after creating them.</td></tr>
<tr><td>--remove-orphans</td><td>Remove containers for services not defined in the Compose file.</td></tr>
</table>

## Build and push a container
### From a running container
```shell
docker run -it python:3.9.6 /bin/bash
# Optionally run a command (example "echo foo > /etc/foo") then "exit"
docker ps -a #Get Container ID from here
docker commit 0b3b31d7d454 pydev-template
docker tag pydev-template:latest dockerrepo.tld/pydev-template:latest
docker push dockerrepo.tld/pydev-template:latest
```
### From a stopped container
```shell
docker pull hello-world:latest
docker tag hello-world:latest dockerrepo.tld/hello-world:latest
docker push dockerrepo.tld/hello-world:latest
```

## Experimenting with salt tiamet
```shell
docker pull saltstack/tiamat
docker tag saltstack/tiamat:latest dockerrepo.tld/tiamet:latest
docker push dockerrepo.tld/tiamet:latest
docker run --name my-maven -it --rm maven:3.8.1-jdk-8 bash
```

## Experimenting with Node
```shell
docker pull node
docker run --rm -it --entrypoint bash node
cd /root
npm install madcert
# Create a Certificate Authority (CA)
npx madcert ca-create test-root-ca --common-name "Test Root CA" --org "Some Organization" --country "US"
# Create an Intermediate CA (Root CA must exist)
npx madcert ca-intermediate-create test-ca test-root-ca --common-name "Test CA" --org-unit "orgA" --org-unit "A123" --org "Some Organization" --country "US"
# Create a Server Certificate (CA must exist)
npx madcert server-create test-server test-ca --common-name "test.server" --org-unit "A123" --org "Some Organization" --country "US" --subject-alt-ip "1.2.3.4"
# List CA Certificates
npx madcert ca-list
```

## Kaniko busybox testing:
```shell
docker run --name kaniko-test -it --rm --entrypoint=/busybox/sh gcr.io/kaniko-project/executor:v1.6.0-debug
# If a another session is needed, from another command prompt run:
docker exec -it kaniko-test /busybox/sh
```
## Gitlab runner testing override entrypoint
```bash
docker run --rm -it --entrypoint bash --name gitlab-runner gitlab/gitlab-runner
```

## Setup docker daemon export on TCP to allow vscode remote docker connection
```shell
vim /etc/systemd/system/multi-user.target.wants/docker.service
# Changeline below:
#ExecStart=
#ExecStart=/usr/bin/dockerd
# Restart to get new config
systemctl daemon-reload
systemctl restart docker.service
```

## What docker repo to use?
Login to docker repository like `docker login artifactory.tld` will save auth info in **~/.docker/config.json**. Example:
```json
{
  "auths": {
  "artifactory.tld": {
  "auth": "<a base64 Code>"
}}}
```

Docker mirror should be set in **/etc/docker/daemon.json** like:
```json
{
  "registry-mirrors": ["https://mirror.artifactory.tld"]
}
```
The "mirror" can act as a virtual repository/pass through to repos in order:
1. docker-local
1. local network artifactory
1. Google GCR
1. AWS ECR
1. GitHub https://ghcr.io/
1. docker.io

## Experimenting with Pypi mirror
```bash
docker run --rm -it --entrypoint bash --name pypitest python:3
pip install python-pypi-mirror
mkdir /pypi
# Download pypi packages
pypi-mirror download -d /pypi requests
pypi-mirror download -d /pypi pygit
pypi-mirror download -d /pypi salt-ssh
# Create a simple mirror (creates in /simple)
pypi-mirror create -d /pypi -m simple
```

# CentOS 7 Docker Notes
CentOS 7 kernel `3.10.0-514` or later is required to use the [overlay2 storage driver](https://docs.docker.com/storage/storagedriver/overlayfs-driver/#configure-docker-with-the-overlay-or-overlay2-storage-driver)

```bash
# Check for "ftype=1"
xfs_info
# Check for Server: "Storage Driver: overlay2" ; "Supports d_type: true"; and "Backing Filesystem: xfs"
docker info
```
