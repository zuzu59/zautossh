# zautossh
Petit script pour gérer les reconnexions automatiques d'un tunnel SSH reverse

README en cours de rédaction (zf180128.1239)

A l'origine c'est pour faire du SSH reverse sur un petit router D-Link DIR505 avec OpenWRT derrière un router 3G/WIFI.
Donc la doc est à adapter en fonction des circonstances du terrain !


# SSH reverse avec OpenWRT
## Documentation ssh
http://www.delafond.org/traducmanfr/man/man1/ssh.1.html

# But
Quand, pour la domotique par exemple (télé remote à quelques centaines de km), on doit se créer un petit réseau bon marché, on va utiliser un petit router 3G/WIFI avec une puce Swisscom prepaid. L'offre actuelle est de 5FS/mois pour 250MB, ce qui est bien assez pour de la domotique.<br>
Mais quand on veut contrôler l'état du prepaid, Swisscom envoie sur le routeur 3G/WIFI un SMS de confirmation, il faut donc être sur place pour pouvoir le consulter.<br>
L'idée est donc de se connecter en remote sur le router 3G/WIFI en SSH pour pouvoir manager le petit router 3G/WIFI !

La problématique est de pouvoir atteindre le réseau distant derrière un router 3G/WIFI connecté via Swisscom via un tremplin SSH sur un petit routeur D-Link DIR505 avec OpenWRT.

Le problème c'est que Swisscom, afin d'économiser les adresses IP V4, NATe ses clients sur un port, donc pas moyen d'accéder directement au routeur OpenWRT de manière standard, vu que l'on n'a pas accès à la configuration de leur NAT :-(

# Moyen
C'est d'utiliser le mode SSH reverse puis de remonter le tunnel SSH construit. Le router OpenWRT se connecte sur un serveur distant tremplin SSH pour créer un tunnel SSH reverse. Après il suffit de remonter depuis le serveur distant tremplin SSH le tunnel SSH et hop, on se retrouve sur le petit routeur OpenWRT et on a alors le total accès aux machines qui se trouvent sur le réseau WIFI.

Bon après vraiment pas mal d'heures passées dessus la commande autossh de openwrt, cela fonctionne bien pour autant que, quand openwrt boot et qu'il a bien le réseau lors du boot. Si par malheur il y a des interruptions du réseau du côté de l'openwrt (WIFI), l'autossh n'est pas capable de redémarrer tout seul car il reste coincé au niveau de l'ancienne connexion avant l'interruption du réseau du côté de l'OpenWRT !

Aussi, bien veiller à mettre un '-y -y' dans la commande ssh de la configuration de autossh, c'est ce qu'il permet de bypasser la vérification de l'host connu, autrement cela ne fonctionne pas.

Comme ce n'était pas utilisable sur le terrain (machine se trouvant à 150km), j'ai récrit un autossh au moyen d'un petit script bash. Comme je lance les tunnels SSH en backgroud avec &, je suis en tout temps maître de pouvoir contrôler le bon fonctionnement du tunnel SSH reverse (pas de blocage). Pour vérifier la bonne connexion, depuis OpenWRT, je fais une boucle SSH pour créer un fichier dans /tmp (connection ssh serveur distant, retour ssh sur OpenWRT), cela me permet vraiment de pouvoir vérifier l'état du tunnel et de le recréer au besoin si jamais.

ATTENTION: dans le cas où il y a eu un perte de réseau au niveau OpenWRT (WIFI) l'ancien tunnel SSH reverse créé sur le tremplin distant est toujours là mais plus actif, il faudra donc se connecter sur le serveur tremplin SSH pour le tuer avec:
sudo netstat -natp |grep LIST (pour trouver le bon pid)
sudo kill -9 pid (le pid du tunnel reverse)



## Commande pour se connecter facilement via le tunnel SSH reverse
Quand cela fonctionne bien, on peut utiliser la ligne de commande magique pour faire directement la connexion depuis le tremplin ssh (ne pas oublier le '-t' afin de pouvoir entrer le password de l'openwrt):

ssh -A -t ubuntu@sdftests.epfl.ch 'ssh root@localhost -p 20221'

Ne pas oublier de faire un:
ssh-add -l
ssh-add
ssh-add -l

Pour ajouter sa clef SSH à l'agent ssh forward qui va envoyer automatiquement la clef ssh sur l'OpenWRT afin de se connecter sans password !


# pour créer le tunnel SSH reverse
Pour créer le tunnel SSH reverse, il suffit simplement de lancer au moment du boot le script:
zautossh.sh



