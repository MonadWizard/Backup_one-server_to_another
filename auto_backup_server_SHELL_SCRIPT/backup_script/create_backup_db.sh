#!/bin/bash

while getopts u:p:s:d: flag
do
    case "${flag}" in
        u) db_username=${OPTARG};;
        p) db_password=${OPTARG};;
        s) db_schema=${OPTARG};;
        d) db_database=${OPTARG};;
    esac
done

path=$db_database-$(date +%d-%m-%Y_%H-%M-%S)

# create database backup

PGPASSWORD="$db_password" pg_dump --host localhost --port 5432 --username "$db_username" --schema "$db_schema" --format custom --blobs --verbose --file "/home/monad/AGL_DBBackup/DataBases/$path.dump" "$db_database"  --verbose 2>/home/monad/AGL_DBBackup/DataBaseLogs/$path.log

#  ./create_backup_db.sh -u 'postgres' -p 'nobodyisshaon' -s 'public' -d 'hr'


#PGPASSWORD="12345" pg_dump --host localhost --port 5432 --username "agl" --schema "public" --format custom --blobs --verbose --file "/home/monad/AGL_DBBackup/DataBases/Probashi_db-$(date +%d-%m-%Y_%H-%M-%S).dump" "probashi_db" --verbose 2>/home/monad/AGL_DBBackup/DataBaseLogs/Probashi_db-$(date +%d-%m-%Y_%H-%M-%S).log

#pg_dump -Fc -h localhost -W --dbname=probashi_db -f dbname.dump --username agl --verbose 2>demo.log

