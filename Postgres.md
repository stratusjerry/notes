## Postgres Notes

### `psql` commands:
Test postgres by execing into postgres pod and running psql (insert the password from above when prompted)
`kubectl exec -it myproj-data-postgresql-0 --namespace myproject --container postgresql -- bash`

```bash
# Connect to Postgres database "postgres" as user "postgres"
psql -d postgres -U postgres  # Password prompt will come up
# List all databases
\l
# Switch to database "mydb"
\c mydb
# List database tables
\dt
# Describe table "mytable"
\d "mytable"
# List all schemas
\dn
# List all views
\dv
# List users and their roles
\du
# List all functions
\df
# Quit
\q
```

### Adding psql to a pod to test myproj-data jdbc connection:

```bash
# Get the "postgres" admin user password
/var/lib/rancher/rke2/bin/kubectl get secret --namespace "mynamespace" "myproj-data-postgresql" -o jsonpath="{.data.postgres-password}" | base64 --decode ; echo
# Get the Postgresql "myadmin" admin user password
#/var/lib/rancher/rke2/bin/kubectl get secret --namespace "mynamespace" "myproj-data-postgresql" -o jsonpath="{.data.password}" | base64 --decode ; echo
# Get the curl-test pod ID to root into (assumes it's already running)
kubectl get pod curl-test -n mynamespace -o jsonpath="{.status.containerStatuses[].containerID}" | sed 's/.*\/\///'
# Use runc to Exec in as root
sudo /var/lib/rancher/rke2/bin/runc --root /run/containerd/runc/k8s.io/ exec -t -u 0 111fb5acfab6cfba1d11111111111111f5cdbb457fd8b4a11f56ef3df111fd9a sh
# Now in pod as root, add postgres
apk update
apk add postgresql
# Login as "postgres" admin user
psql -h myproj-data-postgresql-hl -d postgres -U postgres # -p 5432
# Login as "myadmin" admin user
#psql -h myproj-data-postgresql-hl -d postgres -U myadmin # -p 5432
exit
```

### pgAdmin4

If accessing pgAdmin4 from Dev Cluster [Nodeport](http://myproj-dev-rke2-0.mytld.org:30026/browser/), with User `chart@domain.com` use the values:
- Name: `localhost` (Doesn't really matter)
- Connection: Host name/address: `myproj-dev-rke2-0.mytld.org` (might be able to also use "localhost" or K8S service name `<service-name>.<namespace>.svc.cluster.local`)
- Port: `30025`
- Maintenance database: `mydb` (default is `postgres`)
- Username: `myadmin` (default is `postgres`)
- Password: 
  - `myadmin` user password is result of:
    ```bash
    kubectl get secret --namespace "mynamespace" "myproj-data-postgresql" -o jsonpath="{.data.password}" | base64 --decode ; echo
    ```
  - `postgres` user password is result of:
    ```bash
    kubectl get secret --namespace "mynamespace" "myproj-data-postgresql" -o jsonpath="{.data.postgres-password}" | base64 --decode ; echo
    ```
