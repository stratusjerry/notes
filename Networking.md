## Run a Netcat web server
First, create a file name "test" with contents:
```bash
#!/bin/bash
echo "************PRINT SOME TEXT***************\n"
echo "Hello World!!!"
echo "\n"
echo "Resources:"
vmstat -S M
echo "\n"
echo "Addresses:"
echo "$(ifconfig)"
echo "\n"
```
Next, run netcat
```bash
sudo su  # I think this is required because only root can run processes on special ports
# I think below didn't work consistently
#while true ; do nc -l -p 80 -c 'echo -e "HTTP/1.1 200 OK\n\n $(date)"'; done
while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; sh test; } | nc -l 80; done
while true; do { echo -e 'HTTP/1.1 200 OK\r\n'; sh test; } | nc -l 443; done # Not sure if port 443 worked, I doubt nc can serve certs
```

## Network filters
```bash
sudo tcpdump -i eth0 port not 22 and host not 10.1.1.1  # Filter out SSH and a specified host
sudo tcpdump -i ens5 not port 22 and not arp -vv  # Filter out SSH and ARP, verbosely
sudo tcpdump -i ens5 not port 22 and not arp -w /tmp/dump.pcap # Output to wireshark format file
```
