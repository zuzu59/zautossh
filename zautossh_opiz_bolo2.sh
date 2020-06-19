#!/bin/bash
# Petit script pour lancer un ssh reverse mais surtout aussi de verifier s'il fonctionne, si non il le relance, version pour Ubuntu
#zf180128.0048, zf200619.1022

# pour se connecter: ssh -A -t ubuntu@www.zuzu-test.ml 'ssh ubuntu@localhost -p $ZPORT'
# crontab -e
# @reboot  sleep 30 && /home/ubuntu/zautossh/zautossh_opiz_bolo.sh


ZTIMELOOP=900
ZTREMPLIN_SSH=ubuntu@www.zuzu-test.ml
ZPORT=20223
ZPORTB=21223

while true ; do
    echo "on kill tous les ssh"
    killall -9 ssh
    sleep 2

        echo "on etablit le tunnel ssh reverse"
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R $ZPORT:localhost:22 $ZTREMPLIN_SSH 2>/dev/null &
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R $ZPORT:localhost:22 $ZTREMPLIN_SSH &
        sshpass -p xyz ssh -y -y -N -T -R $ZPORT:localhost:22 $ZTREMPLIN_SSH &
        sleep 3

#        /home/ubuntu/zautossh/msl_mysql.sh

        sleep 6
        echo "on etablit le tunnel ssh normal pour tests"
#        ssh -N -T -L $ZPORTB:localhost:$ZPORT $ZTREMPLIN_SSH 2>/dev/null &
        sshpass -p xyz ssh -y -y -N -T -L $ZPORTB:localhost:$ZPORT $ZTREMPLIN_SSH &
#        sshpass -p tototutufsd ssh -N -L $ZPORTB:localhost:$ZPORT $ZTREMPLIN_SSH &
    sleep 6
        echo "les tunnels sont crees"

    while true ; do
        echo "on test si le tunnel fonctionne"
        rm -f /tmp/toto
#        ssh -y -y root@localhost -p $ZPORTB  2>/dev/null touch /tmp/toto &
        sshpass -p xyz ssh -y -y pi@localhost -p $ZPORTB touch /tmp/toto &
        sleep 6
        ZTEST=`ls /tmp/toto 2>/dev/null`
        ZTEST=$ZTEST"z"
        if [ $ZTEST = "/tmp/toto""z" ]
        then
                echo "le tunnel fonctionne"
        else
                echo `date`", le tunnel est KO"
            echo "on attend un certain temps puis on refait une tentative"
            sleep $ZTIMELOOP
            break
        fi
        echo "on attend un certain temps puis on refait un test"
        sleep $ZTIMELOOP
    done
done

