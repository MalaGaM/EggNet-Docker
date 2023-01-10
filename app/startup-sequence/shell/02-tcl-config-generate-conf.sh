#!/bin/bash
# Need generate or stop ?
[ $EGG_CONF_GENERATE == 0 ] && exit 0

[ -e ${INSTALLDIR}/eggdrop.conf ] && rm ${INSTALLDIR}/eggdrop.conf

mkdir -p ${EGG_PATH_DATA} ${EGG_PATH_LOGS} ${EGG_PATH_CONF} ${EGG_PATH_SCRIPTS}/${IRC_NETNAME}/${EGG_NICK} ${EGG_PATH_SECRETS}
cp ${INSTALLDIR}/eggdrop.conf.dist ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
ln -sfn ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf ${INSTALLDIR}/eggdrop.conf || exit 1

# Server setting
sed -i -e "s/^server add/# server add/" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i -e "/# server add ssl.example.net +7000/c\server add ${IRC_SERVER:-irc.libera.chat} ${IRC_PORT:-+6697} ${IRC_PASSWORD:-}" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

# Eggdrop name irc
sed -i -e "/set nick \"Lamestbot\"/c\set nick \"${EGG_NICK:-Docker-Egg-???}\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

# Listen 
sed -i -e "/#listen 3333 all/c\listen ${EGG_LISTEN:-3333} all" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

# DNS servers
sed -i -e "s/^#set dns-servers/set dns-servers/" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

# Support user mode @&~
sed -i -e '/^set opchars "@"/d' ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i 's/^#set opchars/set opchars/' ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

# ident
sed -i "s@^set username \"lamest\"@set username \"${EGG_USERNAME:-${IRC_NETNAME}}\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set pidfile \"pid.LamestBot\"@set pidfile \"${INSTALLDIR}/bot.pid\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
# no chanmode enforce
sed -i "s@set default-chanmode \"nt\"@set default-chanmode \"\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf


# nick on botnet
sed -i "s@^#set botnet-nick \"LlamaBot\"@set botnet-nick \"${EGG_LONG_NAME}\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

# This setting makes the bot try to get his original nickname back if its primary nickname is already in use.
sed -i -e "/set keep-nick 1/c\set keep-nick ${EGG_KEEP_NICK}" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf


sed -i -e "/#set owner \"MrLame, MrsLame\"/c\set owner \"${EGG_OWNER}\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
# Files names
sed -i -e "/set userfile \"LamestBot.user\"/c\set userfile \"${EGG_PATH_DATA}\/${EGG_NICK}.user\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i -e "/set chanfile \"LamestBot.chan\"/c\set chanfile \"${EGG_PATH_DATA}\/${EGG_NICK}.chan\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i -e "/set notefile \"LamestBot.notes\"/c\set notefile \"${EGG_PATH_DATA}\/${EGG_NICK}.notes\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

sed -i -e "/set realname \"\/msg LamestBot hello\"/c\set realname \"Docker Eggdrop! Visit: https://git.io/JCTIG\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i -e "/set network \"I.didn't.edit.my.config.file.net\"/c\set network \"${IRC_NETNAME:-Default}\"" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i -e '/edit your config file completely like you were told/d' ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i -e '/Please make sure you edit your config file completely/d' ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf



# BOTNET SETTINGS 
echo "### BOTNET SETTINGS ###" >> ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
echo "set EGG_ISMASTER \"${EGG_ISMASTER:-0}\"" >> ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

if [ ! -f "${INSTALLDIR}/eggdrop.sct" ]; then
  EGG_PASSWORD=$(date +%s | sha256sum | base64 | head -c 16)
else
  EGG_PASSWORD=$(cat "${INSTALLDIR}/eggdrop.sct")
fi

echo "set ::EGG_PASSWORD \"${EGG_PASSWORD:-BOTNET}\"" >> ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
# Generate the secret file
echo "${EGG_ISMASTER} ${EGG_PASSWORD} ${EGG_LISTEN:-3333} ${EGG_HOSTNAME} ${EGG_MYIP} ${EGG_LASTMOD}" > ${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.sct
# BOTNET SETTINGS - END


#SASL 
sed -i "s@^#set sasl 0@set sasl 1@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set sasl-mechanism 0@set sasl-mechanism 0@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set sasl-username \"llamabot\"@set sasl-username \"${EGG_NICK}\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set sasl-password \"password\"@set sasl-password \"${PPL_PASS}\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
openssl ecparam -genkey -name prime256v1 -out ${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.pem
sed -i "s@^#set sasl-ecdsa-key \"eggdrop-ecdsa.pem\"@set sasl-ecdsa-key \"${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.pem\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set invite-notify 0@set invite-notify 1@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set message-tags 0@set message-tags 1@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^#set account-tag 0@set account-tag 1@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
openssl genrsa -out ${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.key 4096
sed -i "s@^#set ssl-privatekey \"eggdrop.key\"@set ssl-privatekey \"${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.key\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
openssl req -new -key ${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.key  -x509 -out ${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.crt -days 365 -batch
sed -i "s@^#set ssl-certificate \"eggdrop.crt\"@set ssl-certificate \"${EGG_PATH_SECRETS}/${EGG_LONG_NAME}.crt\"@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf
sed -i "s@^set msg-rate 2@set msg-rate 0@" ${EGG_PATH_CONF}/${EGG_LONG_NAME}.conf

