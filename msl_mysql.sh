#!/bin/bash
#petit script pour lancer un ssh forward pour le serveur mysql du MsL
#zf180128.0048, zf191025.1423

# A lancer directement depuis une machine linux au MsL

ssh ubuntu@www.zuzutest.ml ssh -N -g -L 20881:192.168.1.99:8081 ubuntu@localhost -p 20221 &

sleep 2

ssh ubuntu@www.zuzutest.ml netstat -nat

