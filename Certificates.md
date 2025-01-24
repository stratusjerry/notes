## Password as a variable
This should work
```bash
read -p "enter pw: " -s keypass
# some command that expects a password flag like -pass "pass:$keypass"
unset keypass
```

## OpenSSL
```bash
# Checking Certificate chain to server
openssl s_client -showcerts -connect google.com:443
# Inspecting certificate properties
openssl x509 -in crt.pem -text -noout
openssl pkcs12 -info -in bundle.p12 -nokeys -passin pass:changeme
```

## Java
```bash
# List Certificates in a JKS file
keytool -list -v -keystore /etc/pki/java/cacerts -storepass changeme
keytool -list -v -keystore /etc/pki/java/identity.jks -storepass changeme
keytool -list -v -keystore /etc/pki/java/alltrusted.jks -storepass changeme
```

## Linux CA Certs
### Install required software
```shell
# If Redhat/Ubuntu?
# If Alpine
sudo apk --no-cache add ca-certificates
## Install Alpine Java `keytool` and openssl for debugging
apk add --no-cache java-gcj-compat openssl
```

### Install New CA Certs
```bash
## If Redhat:
cp /tmp/foo.crt /etc/pki/ca-trust/source/anchors/foo.crt
update-ca-trust extract
## If Ubuntu / Alpine:
cp /tmp/foo.crt /usr/local/share/ca-certificates/foo.crt
update-ca-certificates
```
### General Debugging
```shell
# List current CA certs
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
```

## NSSDB (Chrome, Firefox)
```bash
# List all certs in an NSS Database
ln -s /usr/lib/libnssckbi.so ~/.pki/nssdb
certutil -L -d sql:$HOME/.pki/nssdb/ -h 'Builtin Object Token'
# Import custom CA
certutil -d sql:$HOME/.pki/nssdb -A -t "CT,C,C" -n "My Root CA-1" -i /tmp/pki/MyRootCA1.crt
# List custom CA certs
certutil -L -d sql:$HOME/.pki/nssdb/
```
