## docker image for ringserver ##

ftp://ftp.iris.washington.edu/pub/programs/ringserver/

An initial docker image for the ringserver service. Exposes ports
18000, 16000 and the volumes: /etc/ring, /var/lib/ring & /var/log/ring.

The service inside the container runs as the user ringserver with uid/gid 350.

Mark Chadwick
