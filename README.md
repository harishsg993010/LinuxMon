# LinuxMon
An Opensource tool for Event monitoring and logging in Linux (Process creation , Process Close , Networking , Library loads)

# Purpose
1. To help Malware analysts to do dynamic analysis on linux malware
2. To help incident response team to investigate incident

## Instructions
1. sudo chmod +777 linuxmon.sh
2. sudo ./linuxmon.sh
3. log files will be saved in /var/linuxmon/log

## Recomondations
1. Turn this script into linux daemon using systemctl
