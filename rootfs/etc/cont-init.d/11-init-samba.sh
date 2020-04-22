#!/usr/bin/with-contenv sh
# Variable Valiation

if [ -z "$HOSTNAME" ]; then
  NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
else
  NETBIOS_NAME=$(echo $HOSTNAME | tr [a-z] [A-Z])
fi


if [ ! -f /var/lib/samba/registry.tdb ]; then
  # Perform SAMBA setup
  if [ "$BIND_INTERFACES_ONLY" == yes ]; then
    INTERFACE_OPTS="--option=\"bind interfaces only=yes\" \
      --option=\"interfaces=$INTERFACES\""
  fi
  if [ $DEPLOYMENT == provision ]; then
    PROVISION_OPTS="--server-role=dc --use-rfc2307 --domain=$SAMBA_DOMAIN \
    --realm=$SAMBA_REALM --adminpass='$ADMIN_PASSWORD' --dns-backend='$SAMBA_BACKEND' \
    --host-name='$HOSTNAME'"
  elif [ $DEPLOYMENT == join ]; then
    PROVISION_OPTS="$SAMBA_REALM DC -UAdministrator --password='$ADMIN_PASSWORD'"
  else
    echo 'Only provision and join actions are supported.'
    exit 1
  fi
  # Deploy
  echo "samba-tool domain $DEPLOYMENT $PROVISION_OPTS $INTERFACE_OPTS \
     --dns-backend=SAMBA_INTERNAL" | sh

  # Backup default/generated config
  mv /etc/samba/smb.conf /etc/samba/smb.conf.back
  mkdir -p -m 0700 /etc/samba/conf.d
  # Update config files
  for file in $(find /template -type f -name "*.conf"); do
    fileName=$(basename $file)
    # directory=$(basename $(dirname $file))
    destination=
    if [ $fileName == 'smb.conf' ]; then
      destination=/etc/samba/
    else
      destination=/etc/samba/conf.d/
    fi
    # Ok replace and paste
    sed -e "s:{{ HOSTNAME }}:$HOSTNAME:" \
      -e "s:{{ DOMAIN_LOGONS }}:$DOMAIN_LOGONS:" \
      -e "s:{{ DOMAIN_MASTER }}:$DOMAIN_MASTER:" \
      -e "s:{{ SAMBA_REALM }}:$SAMBA_REALM:" \
      -e "s:{{ SERVER_STRING }}:$SERVER_STRING:" \
      -e "s:{{ SAMBA_WORKGROUP }}:$SAMBA_DOMAIN:" \
      -e "s:{{ BIND_INTERFACES_ONLY }}:$BIND_INTERFACES_ONLY:" \
      -e "s+{{ BIND_INTERFACES }}+$BIND_INTERFACES+" \
      -e "s:{{ LOG_LEVEL }}:$LOG_LEVEL:" \
      -e "s:{{ WINBIND_USE_DEFAULT_DOMAIN }}:$WINBIND_USE_DEFAULT_DOMAIN:" \
      -e "s:{{ ALLOW_DNS_UPDATES }}:$ALLOW_DNS_UPDATES:" \
      -e "s:{{ DNS_FORWARDER }}:$DNS_FORWARDER:" \
      $file > $destination$fileName
  done
  # Link krb5.conf
  ln -fns /var/lib/samba/private/krb5.conf /etc/krb5.conf
  # Done
  echo 'root = administrator' > /etc/samba/smbusers
  
fi
# We need to re-link krb5.conf, need to check if this is to be done post each reboot
ln -s /samba/lib/private/krb5.conf /etc/krb5.conf
