# Script que realiza o dump do banco do roundcube. Mantem as ultimas 7 copias por seguranca
# Criado por ricardo

DATADIR="/home/adminuser/"
USERNAME="dumpuser"
PASSWORD="adminuser"
NOW=$(date +"%d-%m-%Y")

#Faz Backup colocando a data no nome do arquivo
/usr/bin/mysqldump -u $USERNAME -p$PASSWORD --databases moodle > $DATADIR/moodle.$NOW.sql
if [ "$?" -ne "0" ]; then
        echo "Falha na copia do banco moodle!"
        exit 1
fi
echo "Fim mysqldump"

tar -czf $DATADIR/moodle-$NOW.tar.gz /var/www/moodle
if [ "$?" -ne "0" ]; then
        echo "Falha na copia do diretorio moodle!"
        exit 1
fi
echo "Fim copia do diretorio moodle"

tar -czf $DATADIR/moodledata-$NOW.tar.gz /var/www/moodledata
if [ "$?" -ne "0" ]; then
        echo "Falha na copia do diretorio moodledata!"
        exit 1
fi
echo "Fim copia do diretorio moodledata"


# Remove arquivos do diretório informado com mais de uma semana (7 dias)
find $DATADIR -mtime +6 -exec rm {} \;
