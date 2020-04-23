# TundraSoft - SAMBA Docker

Samba is Free Software licensed under the GNU General Public License, the Samba project is a member of the Software Freedom Conservancy.

This is based out of https://hub.docker.com/r/instantlinux/samba-dc/

# Usage

**NOTE** - This docker has to be run in privileged mode

You can run the docker image by

## docker run

```
docker run \
 --name=samba-ad-dc \
 -p 88:88 \
 -p 88:88/udp \
 -p 135:135 \
 -p 137-138:137-138/udp  \
 -p 139:139 \
 -p 389:389 \
 -p 389:389/udp \
 -p 445:445 \
 -p 464:464/udp \
 -p 636:636 \
 -p 3268-3269:3268-3269 \
 -p 49152-65535:49152-65535 \
 -e PUID=1000 \
 -e PGID=1000 \
 -e TZ=Europe/London \
 -e DEPLOYMENT="provision" \
 -e ADMIN_PASSWORD="samba-password" \
 -e PROCESS_MODEL="standard" \
 -e SAMBA_REALM="example.local" \
 -e SAMBA_DOMAIN="EXAMPLE" \
 -e SAMBA_BACKEND="SAMBA_INTERNAL" \
 -e DOMAIN_LOGONS="yes" \
 -e DOMAIN_MASTER="no" \
 -e HOSTNAME="ad1" \
 -e WINBIND_USE_DEFAULT_DOMAIN="yes" \
 -e BIND_INTERFACES_ONLY=no \
 -e BIND_INTERFACES= \
 -e ALLOW_DNS_UPDATES="secure" \
 -e DNS_FORWARDER="10.1.1.1" \
 -e LOG_LEVEL=1 \
 -v samba_config:/etc/samba/ \
 -v samba_data:/var/lib/samba/ \
 --privileged \
 --restart unless-stopped \
 tundrasoft/samba-ad-docker:latest
```

## docker Create

```
docker create \
 --name=samba-ad-dc \
 -p 88:88 \
 -p 88:88/udp \
 -p 135:135 \
 -p 137-138:137-138/udp  \
 -p 139:139 \
 -p 389:389 \
 -p 389:389/udp \
 -p 445:445 \
 -p 464:464/udp \
 -p 636:636 \
 -p 3268-3269:3268-3269 \
 -p 49152-65535:49152-65535 \
 -e PUID=1000 \
 -e PGID=1000 \
 -e TZ=Europe/London \
 -e DEPLOYMENT="provision" \
 -e ADMIN_PASSWORD="samba-password" \
 -e PROCESS_MODEL="standard" \
 -e SAMBA_REALM="example.local" \
 -e SAMBA_DOMAIN="EXAMPLE" \
 -e SAMBA_BACKEND="SAMBA_INTERNAL" \
 -e DOMAIN_LOGONS="yes" \
 -e DOMAIN_MASTER="no" \
 -e HOSTNAME="ad1" \
 -e WINBIND_USE_DEFAULT_DOMAIN="yes" \
 -e BIND_INTERFACES_ONLY=no \
 -e BIND_INTERFACES= \
 -e ALLOW_DNS_UPDATES="secure" \
 -e DNS_FORWARDER="10.1.1.1" \
 -e LOG_LEVEL=1 \
 -v samba_config:/etc/samba/ \
 -v samba_data:/var/lib/samba/ \
 --privileged \
 --restart unless-stopped \
 tundrasoft/samba-ad-docker:latest
```

## docker-compose

```
version: "3.2"
services:
  samba-ad-dc:
    image: tundrasoft/samba-ad-docker:latest
    ports:
      - 88:88
      - 88:88/udp
      - 135:135
      - 137-138:137-138/udp
      - 139:139
      - 389:389
      - 389:389/udp
      - 445:445
      - 464:464/udp
      - 636:636
      - 3268-3269:3268-3269
      - 49152-65535:49152-65535
    environment:
      - PUID=1000 # for UserID
      - PGID=1000 # for GroupID
      - TZ=Asia/Kolkata # Specify a timezone to use EG Europe/London
      - DEPLOYMENT="provision"
      - ADMIN_PASSWORD="samba-password"
      - PROCESS_MODEL="standard"
      - SAMBA_REALM="example.local"
      - SAMBA_DOMAIN="EXAMPLE"
      - SAMBA_BACKEND="SAMBA_INTERNAL"
      - DOMAIN_LOGONS="yes"
      - DOMAIN_MASTER="no"
      - HOSTNAME="ad1"
      - WINBIND_USE_DEFAULT_DOMAIN="yes"
      - BIND_INTERFACES_ONLY=no
      - BIND_INTERFACES=
      - ALLOW_DNS_UPDATES="secure"
      - DNS_FORWARDER="10.1.1.1"
      - LOG_LEVEL=1
    volumes:
      - <path to config>:/etc/samba/ # Where transmission should store config files and logs.
      - <path to download>:/var/lib/samba/ # Local path for downloads (complete, incomplete and watch are sub folders)
    privileged: true
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
```

## Ports

88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535

## Variables

### PUID

The User ID to use to run the process as. This is primarily to ensure permission matches between the remote system and container (defaults to 1000)

### PGID

The Group ID to use to run the process as. This is primarily to ensure permission matches between the remote system and container (defaults to 1000)

### TZ

The timezone to use.

### DEPLOYMENT

Deployment mode, options are provision or join. Provision will setup as a server while join would join an existin ad

### ADMIN_PASSWORD

Password for administrator user. Defaults to p@ssw0rd

**NOTE** - PASSWORD NEEDS TO BE 8 CHARS long, with numer and special character

### PROCESS_MODEL

Run samba process in standard, preform or single. Defaults to standard. Use prefork in large scale deployments

standard - This is the default mode where each service runs as a seperate process. For services that support it (LDAP and NETLOGON), a separate process is forked for every accepted connection from a client.

prefork - Each Samba service (LDAP, RPC, etc) runs in a separate process. A fixed number of worker processes are started for those services that support it (currently LDAP, NETLOGON, and KDC). Instead of forking a separate process for each client connection, the connections are shared amongst the existing worker processes. Requests for services not supporting prefork are handled by a single process for that service.

single - Everything gets done in a single process. This is recommended only for testing and debugging, not for production networks.

### SAMBA_REALM

The domain name (FQDN)
Defaults to EXAMPLE.LOCAL

### SAMBA_DOMAIN

The hostname. Just the hostname needs to be entered

### SAMBA_BACKEND

The backend to use for DNS. Currently only SAMBA_INTERNAL is supported.

### DOMAIN_LOGONS

Enable domain logins

### DOMAIN_MASTER

Is this a domain master. Defaults to no.
Accepted values yes or no

Default is no

### WINBIND_USE_DEFAULT_DOMAIN

Allow username without domain component

### BIND_INTERFACES_ONLY

Not Implemented, planned for future. DO NOT USE

Enable samba to bind to specific interfaces

### BIND_INTERFACES

Not Implemented, planned for future. DO NOT USE

Binds services to a specific ethernet port or IP address. This requires BIND_INTERFACES_ONLY to be enabled

### ALLOW_DNS_UPDATES

Not Implemented, planned for future. DO NOT USE

### DNS_FORWARDER

When backend is set to SAMBA_INTERNAL, samba will only resolve AD DNS zones. For recursive queries a forwarder needs to be provided. Usually this is your switch's ip address

Defaults to 10.1.1.1

### LOG_LEVEL

The log level settings in samba. Defaults to 1. You can set a value between 1 - 10 for more detailed logging
