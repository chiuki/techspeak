#!/bin/bash

RAW_DIR="raw"
INDEX_FILE="${RAW_DIR}/index.html"
TMP_FILE="tmp.html"
OUTPUT_FILE="links.tsv"

if [ ! -d ${RAW_DIR} ]; then
 mkdir ${RAW_DIR}
fi

curl "http://tinyletter.com/techspeak/archive" > ${INDEX_FILE}

for url in `grep message-link ${INDEX_FILE} | cut -f4 -d\"`; do
  basename=`basename ${url} | sed -e 's/technically.speaking.//g'`
  month=`echo ${basename} | cut -f1 -d\-`
  day=`echo ${basename} | cut -f2 -d\- | sed -e 's/[a-z]*$//g'`
  year=`echo ${basename} | cut -f3 -d\- | sed -e 's/20115/2015/g'`
  published_date=`date -d "${month} ${day} ${year}" +"%Y%m%d"`
  output=${RAW_DIR}/${published_date}.html
  if [ ! -f ${output} ]; then
    curl ${url} > ${output}
  fi
done

for file in ${RAW_DIR}/2???????.html; do
  echo ${file}
  published_date=`basename ${file} | cut -f1 -d.`
  formatted_date=`date -d ${published_date} +'%-d-%b-%Y'`
  grep -q ${formatted_date} ${OUTPUT_FILE}
  if [ $? -eq 0 ]; then
    echo "  Already processed"
  else
    count=0
    for url in `egrep -o "\[.*a.href.*\[.*tweet it.*\]" ${file} | cut -f2 -d\"`; do
      url_effective=`curl -Ls -o ${TMP_FILE} -w %{url_effective} ${url}`
      title=`awk -vRS="</title>" '/<title>/{gsub(/.*<title>|\n+/,"");print;exit}' ${TMP_FILE}`
      rm -f ${TMP_FILE}
      echo -n ${formatted_date} >> ${OUTPUT_FILE}
      echo -en '\t' >> ${OUTPUT_FILE}
      echo -n ${title} >> ${OUTPUT_FILE}
      echo -en '\t' >> ${OUTPUT_FILE}
      echo ${url} >> ${OUTPUT_FILE}
      count=`expr ${count} + 1`
    done
    echo "  Number of links extracted: ${count}"
  fi
done
