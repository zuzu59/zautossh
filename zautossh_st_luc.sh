#!/bin/ash
#petit script pour lancer un ssh reverse mais surtout aussi de verifier s'il fonctionne, si non il le relance
#zf180204.1306, zf180325.1506, zf211212.1457, zf230514.2129

## pour se connecter: ssh -A -t ubuntu@sdftests.epfl.ch 'ssh root@localhost -p 20221'
# pour se connecter sur le D-link via le tunnel ssh reverse: ssh -A -t ubuntu@zuzu-test.go4.ch ssh root@localhost -p 20225'

ZTIMEPOWERON=60
ZTIMELOOP=10
ZTIMEWAIT=10
ZTIMERETRY=10

# on attend que le reseau soit bien etabli avant de demarrer les tunnels lors du power boot
echo ""
echo `date`", start script zautossh.sh et on attend que le réseau se stabilise"
sleep $ZTIMEPOWERON
echo `date`", c'est parti !"
while true ; do
	echo "on kill tous les ssh"
	killall -9 ssh 2>/dev/null
	sleep 10

        echo "on etablit le tunnel ssh reverse"
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R 20221:localhost:22 ubuntu@sdftests.epfl.ch 2>/dev/null &
#        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R 20221:localhost:22 ubuntu@sdftests.epfl.ch &
        ssh -i /root/.ssh/id_dropbear -y -y -N -T -R 20225:localhost:22 ubuntu@zuzu-test.go4.ch &
        echo "le tunnel ssh reverse est etablit !"
        sleep 10

        echo "on etablit le tunnel ssh normal pour tests"
#        ssh -N -T -L 21221:localhost:20221 ubuntu@sdftests.epfl.ch 2>/dev/null &
#        ssh -y -y -N -T -L 21221:localhost:20221 ubuntu@sdftests.epfl.ch &
        ssh -y -y -N -T -L 21225:localhost:20225 ubuntu@zuzu-test.go4.ch &
        echo "le tunnel de tests est cree"
	sleep 10

	while true ; do
		echo "on test si le tunnel fonctionne"
		rm -f /tmp/toto
#		ssh -y -y root@localhost -p 21221  2>/dev/null touch /tmp/toto &
		ssh -y -y root@localhost -p 21225 touch /tmp/toto &
		sleep $ZTIMEWAIT
		ZTEST=`ls /tmp/toto 2>/dev/null`
		ZTEST=$ZTEST"z"
		if [ $ZTEST = "/tmp/toto""z" ]
		then
        		echo "le tunnel fonctionne"
#			echo "."
		else
	        	echo `date`", le tunnel est KO"
			echo "on attend un certain temps puis on refait une tentative"
			sleep $ZTIMERETRY
			break
		fi
#		echo "on attend un certain temps puis on refait un test"
		sleep $ZTIMELOOP
	done
done

