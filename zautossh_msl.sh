#!/bin/bash
#petit script pour lancer un ssh reverse mais surtout aussi de verifier s'il fonctionne, si non il le relance, version pour Ubuntu
# ATTENTION, il relance aussi le tunnel forward pour le mysql du MsL
#zf180128.0048, zf191025.1433, zf200422.2117

# pour se connecter: ssh -A -t ubuntu@www.zuzu-test.ml 'ssh ubuntu@localhost -p 20221'

# crontab -e
# @reboot  sleep 30 && /home/ubuntu/zautossh/zautossh_msl.sh



ZTIMELOOP=30

while true ; do
	echo "on kill tous les ssh"
	killall -9 ssh
	sleep 10

        echo "on etablit le tunnel ssh reverse"
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R 20221:localhost:22 ubuntu@www.zuzutest.ml 2>/dev/null &
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R 20221:localhost:22 ubuntu@www.zuzutest.ml &
        ssh -y -y -N -T -R 20221:localhost:22 ubuntu@www.zuzu-test.ml &
        sleep 10
        echo "on etablit le tunnel ssh pour mysql"
        /home/ubuntu/zautossh/msl_mysql.sh
        sleep 10
        echo "on etablit le tunnel ssh normal pour tests"
#        ssh -N -T -L 21221:localhost:20221 ubuntu@www.zuzutest.ml 2>/dev/null &
        ssh -y -y -N -T -L 21221:localhost:20221 ubuntu@www.zuzu-test.ml &
	    sleep 10
        echo "les tunnels sont crees"

	while true ; do
		echo "on test si le tunnel fonctionne"
		rm -f /tmp/toto
#		ssh -y -y root@localhost -p 21221  2>/dev/null touch /tmp/toto &
		ssh -y -y ubuntu@localhost -p 21221 touch /tmp/toto &
		sleep 10
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
