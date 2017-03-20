#!/bin/bash

function usage
{
    echo "usage: restore_db [[-f filepath -c container] | [-h]]"
}

while [[ $# -gt 1 ]]
do
    key="$1"
    case $key in
        -f | --file )           
        filepath=$2
        shift
        ;;
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
user=finance
database=${project}_${environment}

docker exec -i $container psql -U $user $database < "${filepath}"

