## Installing `redis-cli`

```bash
git clone http://github.com/antirez/redis
cd redis/
git checkout "7.2.4"
make redis-cli
#ln -s src/redis-cli /usr/local/bin/redis-cli
# Run PING
./src/redis-cli -h myhost.tld -p 31000 PING
# Run PING, using a password
./src/redis-cli -h myhost.tld -p 31000 -a "PASSWORD" PING
# Interactively connect, using a password
./src/redis-cli -h myhost.tld -p 31000 -a "PASSWORD"
myhost.tld:31000> PING
# set and get a key
myhost.tld:31000> SET testkey "Hello, Redis!"
myhost.tld:31000> GET testkey
myhost.tld:31000> quit
```

Optionally, use a GoLang fork
```bash
wget https://github.com/holys/redis-cli/releases/download/v0.0.2/redis-cli-v0.0.2-linux-amd64
mv redis-cli-v0.0.2-linux-amd64 redis-cli
chmod +x redis-cli
./redis-cli -h myhost.tld -p 31000
myhost.tld:31000> get info
myhost.tld:31000> exit
```

Redis Commands
```bash
# Get a list of client connections
CLIENT LIST
#
DBSIZE
COMMAND  # Get array of Redis command details
RANDOMKEY  # Return a random key from the keyspace
cluster info
QUIT
```
