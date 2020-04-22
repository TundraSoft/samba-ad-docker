FROM tundrasoft/alpine-base
LABEL maintainer="Abhinav A V<abhai2k@gmail.com>"

# SAMBA Config variables and defaults
ENV DEPLOYMENT="provision" \
  ADMIN_PASSWORD="p@ssw0rd" \
  PROCESS_MODEL="standard" \
  SAMBA_REALM="example.local" \
  SAMBA_DOMAIN="EXAMPLE" \
  SAMBA_BACKEND="SAMBA_INTERNAL" \
  DOMAIN_LOGONS="yes" \
  DOMAIN_MASTER="no" \
  HOSTNAME="ad1" \
  WINBIND_USE_DEFAULT_DOMAIN="yes" \
  BIND_INTERFACES_ONLY=no \
  BIND_INTERFACES=\
  ALLOW_DNS_UPDATES="secure"\
  DNS_FORWARDER="10.1.1.1" \
  LOG_LEVEL=1

RUN apk add --update samba-dc \
  krb5 \
  ldb-tools

ADD /rootfs/ /

# Cleanup
RUN rm -rf /etc/samba/ \
  /etc/krb5.conf \
  /var/cache/apk/* \
  /root/.cache \
  /tmp/*

# Volumes
VOLUME [ "/etc/samba", "/var/lib/samba" ]
# Ports
# EXPOSE 22 389 88 123/udp 135 139 138 445 464 3268 3269 
EXPOSE 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535