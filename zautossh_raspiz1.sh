#!/bin/bash
#petit script pour lancer un ssh reverse mais surtout aussi de verifier s'il fonctionne, si non il le relance, version pour Ubuntu
# ATTENTION, il relance aussi le tunnel forward pour le mysql du MsL
#zf180128.0048, zf200417.0052

# il faut copier les clefs ssh
## ssh-copy-id ubuntu@www.zuzu-test.ml
## ssh-copy-id pi@localhost

# il faut le mettre dans le crontab
## crontab -e
## @reboot  sleep 30 && /home/pi/zautossh/zautossh_raspiz1.sh

# pour se connecter: ssh -A -t ubuntu@www.zuzu-test.ml 'ssh pi@localhost -p 20224'


ZTIMELOOP=30
ZTREMPLIN_SSH=ubuntu@www.zuzu-test.ml
ZPORT=20224
ZPORTB=21224
ZUSER_LOCAL=pi

while true ; do
	echo "on kill tous les ssh"
	killall -9 ssh
	sleep 2

        echo "on etablit le tunnel ssh reverse"
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R $ZPORT:localhost:22 $ZTREMPLIN_SSH 2>/dev/null &
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R $ZPORT:localhost:22 $ZTREMPLIN_SSH &
        ssh -y -y -N -T -R $ZPORT:localhost:22 $ZTREMPLIN_SSH &
        sleep 3

#        /home/ubuntu/zautossh/msl_mysql.sh

        sleep 6
        echo "on etablit le tunnel ssh normal pour tests"
#        ssh -N -T -L $ZPORTB:localhost:$ZPORT $ZTREMPLIN_SSH 2>/dev/null &
        ssh -y -y -N -T -L $ZPORTB:localhost:$ZPORT $ZTREMPLIN_SSH &
	sleep 6
        echo "les tunnels sont crees"

	while true ; do
		echo "on test si le tunnel fonctionne"
		rm -f /tmp/toto
#		ssh -y -y root@localhost -p $ZPORTB  2>/dev/null touch /tmp/toto &
		ssh -y -y $ZUSER_LOCAL@localhost -p $ZPORTB touch /tmp/toto &
		sleep 12
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
