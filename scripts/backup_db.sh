#!/bin/bash

function usage
{
    echo "usage: backup_db [[-c container] | [-h]]"
}

while [[ $# -gt 1 ]]
do
    key="$1"
    case $key in
        -c | --container )
        container=$2
        shift
        ;;
        -h | --help )
        usage
        exit
        ;;
        * )
        usage
        exit 1
	;;
    esac
    shift
done

environment=development
project=finance
dir=/Users/abp/dev/finance/backups
output=$dir/${project}_${environment}_`date +%Y%m%d"_"%H_%M_%S`.sql
user=finance
database=${project}_${environment}

mkdir -p $dir


echo "${output}"

docker exec -i $container pg_dumpall -c -l $database -U $user > "${output}"

