# docker-ringserver
#
# VERSION 0.0.1
#

#
#ringserver version 2014.269
#
#Usage: ringserver [options] [configfile]
#
# ## Options ##
# -V             Print program version and exit
# -h             Print this usage message
# -H             Print an extended usage message
# -v             Be more verbose, multiple flags can be used
# -I serverID    Server ID (default 'Ring Server')
# -m maxclnt     Maximum number of concurrent clients (currently 600)
# -Rd ringdir    Directory for ring buffer files, required
# -Rs bytes      Ring packet buffer file size in bytes (default 1 Gigabyte)
# -Rm maxid      Maximum ring packet ID (currently 16777215)
# -Rp pktsize    Maximum ring packet data size in bytes (currently 512)
# -NOMM          Do not memory map the packet buffer, use memory instead
# -DL port       Listen for DataLink connections on port (default off)
# -SL port       Listen for SeedLink connections on port (default off)
# -T logdir      Directory to write transfer logs (default is no logs)
# -Ti hours      Transfer log writing interval (default 24 hours)
# -Tp prefix     Prefix to add to transfer log files (default is none)
# -STDERR        Send all console output to stderr instead of stdout
#

FROM centos:centos7
MAINTAINER Mark Chadwick m.chadwick@gns.cri.nz

RUN yum clean expire-cache
RUN yum install -y man tar make gcc

ENV RINGSERVER_UID 350
ENV RINGSERVER_GID 350

ENV RINGSERVER_VERSION 2014.269
ENV RINGSERVER_URL https://seiscode.iris.washington.edu/attachments/download/595

WORKDIR /tmp
ADD $RINGSERVER_URL/ringserver-$RINGSERVER_VERSION.tar.gz /tmp/ringserver.tar.gz
RUN tar xvzf /tmp/ringserver.tar.gz
RUN cd /tmp/ringserver-$RINGSERVER_VERSION && \
        make && \
        cp -a ringserver /usr/bin && \
        cp -a doc/ringserver.1 /usr/share/man/man1/ringserver.1

RUN groupadd -g $RINGSERVER_GID -r ringserver && useradd -u $RINGSERVER_UID -r -g ringserver ringserver
RUN mkdir -p /var/lib/ring && chown ringserver:ringserver /var/lib/ring
RUN mkdir -p /var/log/ring && chown ringserver:ringserver /var/log/ring
RUN mkdir -p /etc/ring && chown ringserver:ringserver /etc/ring
RUN cd /tmp/ringserver-$RINGSERVER_VERSION && \
        cp -a doc/ring.conf /etc/ring/ring.conf && \
        chown ringserver:ringserver /etc/ring/ring.conf
RUN echo WriteIP 0.0.0.0/0 >> /etc/ring/ring.conf

USER ringserver
VOLUME /etc/ring
VOLUME /var/lib/ring
VOLUME /var/log/ring

EXPOSE 18000
EXPOSE 16000

ENTRYPOINT ["/usr/bin/ringserver", "/etc/ring/ring.conf", "-Rd", "/var/lib/ring", "-SL", "18000"]
