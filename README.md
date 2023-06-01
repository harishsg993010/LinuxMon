# LinuxMon
An Opensource tool for Event monitoring in Linux (Process creation , Process Close , Networking , Library loads)

# Purpose
1. logging which might help forensic analyst to investigate a cyber attack involving linux ecosystem
2. To help Malware analysts to do dynamic anakysis on linux malware

## Intructions
1. sudo chmod +777 linuxmon.sh
2. sudo ./linuxmon.sh
3. log files will be saved in /var/linuxmon/log

## Recomondations
1. Turn this script into linux daemon using systemctl
