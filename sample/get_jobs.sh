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

DIR=jobs
ITEM_PATH=${DIR}/${ITEM}
TEMPLATE_LINK=https://www.freelancer.com/jobs/${ITEM}/XXX/

# get first index.html
if [ -d "${ITEM_PATH}" ]; then
	rm -rf ${ITEM_PATH}/*;
else
	mkdir -p ${ITEM_PATH};
fi

FIRST_LINK=https://www.freelancer.com/jobs/${ITEM}/1/
echo "Downloading ${FIRST_LINK}";
wget -O ${ITEM_PATH}/index.html ${FIRST_LINK} >& /dev/null;

# get entries info
ENTRIES_INFO=`get_entries ${ITEM_PATH}/index.html`

START_ENTRY=`echo ${ENTRIES_INFO} | awk -F\  '{ print $2}'`
END_ENTRY=`echo ${ENTRIES_INFO} | awk -F\  '{ print $4}'`
ALL_ENTRIES=`echo ${ENTRIES_INFO} | awk -F\  '{ print $6}'`

ALL_PAGES=$((${ALL_ENTRIES} / ${END_ENTRY}))

if [ $((${ALL_ENTRIES} % ${END_ENTRY})) -gt 0 ]; then
    ALL_PAGES=$((${ALL_PAGES} + 1));
fi

echo "========== INFO =========="
echo "START: ${START_ENTRY}"
echo "END:   ${END_ENTRY}"
echo "ALL:   ${ALL_ENTRIES}"
echo "STEP:  ${ALL_PAGES}"
echo "=========================="

STEP=1

printf "ITEM: %d..." ${STEP};
find_links ${ITEM_PATH}/index.html | grep "www.freelancer.com/projects" > ${DIR}/${ITEM}.link;

while [ ${STEP} -lt ${ALL_PAGES} ]; do
    STEP=$(( ${STEP} + 1 ));
    LINK=`echo ${TEMPLATE_LINK} | sed -e "s/XXX/${STEP}/g"`;
    printf "%d..." ${STEP};
    wget -O ${ITEM_PATH}/index_${STEP}.html ${LINK} >& /dev/null;
    find_links ${ITEM_PATH}/index_${STEP}.html | grep "www.freelancer.com/projects" >> ${DIR}/${ITEM}.link;
done

echo "FINSIHED";


