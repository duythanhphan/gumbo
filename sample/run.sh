#!/bin/sh

DIR=output
ITEM=IPAD
ITEM_PATH=${DIR}/${ITEM}

TEMPLATE_LINK=https://www.freelancer.com/jobs/${ITEM}/XXX/index.html

# get first index.htmal
if [ -d "${ITEM_PATH}" ]; then
	rm -rf ${ITEM_PATH}/*;
else
	mkdir ${ITEM_PATH};
fi

FIRST_LINK=https://www.freelancer.com/jobs/${ITEM}/1/index.html
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

find_links ${ITEM_PATH}/index.html | grep "www.freelancer.com/projects";

STEP=1
#ALL_PAGES=5
while [ ${STEP} -lt ${ALL_PAGES} ]; do
    STEP=$(( ${STEP} + 1 ));
    LINK=`echo ${TEMPLATE_LINK} | sed -e "s/XXX/${STEP}/g"`;
    #echo "Downloading ${LINK}";
    wget -O ${ITEM_PATH}/index_${STEP}.html ${LINK} >& /dev/null;
    find_links ${ITEM_PATH}/index_${STEP}.html | grep "www.freelancer.com/projects";
done
