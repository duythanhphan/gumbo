#!/bin/sh

while getopts i: var; do
    case "$var" in
    i) ITEM=$OPTARG ;;
    esac
done

if [ -z "${ITEM}" ]; then
    echo "Usage: get_jobs -i <ITEM>";
    echo "( ITEM: IPHONE | IPAD | ANDROID | MACHINE-LEARNING | DATA-PROCESSING | DATA-MINING
        NATURAL-LANGUAGE | ALGORITHM  | CRYTOGRAPHY )";
    exit 1;
fi

JOBDIR=jobs
PROJDIR=projects
ITEM_PATH=${JOBDIR}/${ITEM}

LINKFILE=${JOBDIR}/${ITEM}.link

# get first index.htmal
if [ ! -f "${LINKFILE}" ]; then
    echo "Error:> ${LINKFILE} not found !!!";
    exit 1;
fi

for i in `cat ${LINKFILE}`; do 
    __dir=`dirname ${i} | sed -e "s/http\:\/\/www.freelancer.com\///g"`; 
    __base=`basename ${i}`;
    
    if [ ! -d "${__dir}" ]; then
	mkdir -p ${__dir};
    fi
    
    echo "Gettting ${i}";
    wget -O ${__dir}/${__base} ${i} >& /dev/null;
done
