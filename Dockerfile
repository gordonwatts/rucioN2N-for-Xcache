FROM gordonwatts/rucio-base:v1.0.1
# TODO: We don't actually need rucio, but it has all the certificates built in. Which makes
# this easy. We should really layer out the design more... but we might not be using this
# much longer... so...

RUN yum install -y curl gperftools hostname sudo

RUN curl -s -o /etc/yum.repos.d/xrootd-stable-slc7.repo http://www.xrootd.org/binaries/xrootd-stable-slc7.repo
RUN curl -s -o /etc/pki/rpm-gpg/RPM-GPG-KEY-wlcg http://linuxsoft.cern.ch/wlcg/RPM-GPG-KEY-wlcg
RUN curl -s -o /etc/yum.repos.d/wlcg-centos7.repo http://linuxsoft.cern.ch/wlcg/wlcg-centos7.repo
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

RUN yum install -y xrootd-server xrootd-client xrootd libmacaroons
RUN yum install -y xrootd-rucioN2N-for-Xcache
RUN yum install -y vomsxrd

# Generic setup of directories, etc. for xrootd
RUN echo "g /atlas / rl" > /etc/xrootd/auth_db
RUN mkdir -p /etc/grid-security/xrd
RUN touch /etc/grid-security/xrd/xrdcert.pem
RUN touch /etc/grid-security/xrd/xrdkey.pem

RUN touch /etc/xrootd/xcache.cfg /var/run/x509up

# Copy over the various config files we need
COPY xcache.cfg.template /etc/xrootd/xcache.cfg.template

RUN mkdir -p /data
RUN chown -R xrootd:xrootd /data

WORKDIR /var/spool/xrootd
COPY runme.sh .
RUN chown -R xrootd:xrootd runme.sh
RUN chmod a+x runme.sh
COPY bashrc .bashrc

# Where to place the grid cert so everyone that runs in here can find it.
ENV X509_USER_PROXY /var/spool/xrootd/x509up

# Start the server up!
ENTRYPOINT [ "/bin/bash", "-c", "sudo -u xrootd /var/spool/xrootd/runme.sh" ]
