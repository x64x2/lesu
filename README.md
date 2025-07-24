

tordrop is a bash script to modify IPTABLES rules to prevent Tor users (see <http://www.torproject.org/>) from connecting to your host

## installation

iptables, ipset and wget must be installed so that this programm can be executed.

as iptables and ipset are called, this program must be executed by root.

as Tor exit nodes are continually renewed, you should run this program with root crontab.

One execution every 20 minutes may be a good frequency and the crontab instruction should look like this 

> :*/20 * * * * /path/to/tor-dropper.sh
