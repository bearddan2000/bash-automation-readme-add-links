#!/usr/bin/env bash

REPO_NAME="test"

function write_search_to_file() {
  #statements
  local data_file=README.md

  echo  >> $data_file

  echo "$2 search" >> $data_file

  for s in `echo $1 | awk '{print $0}'`; do
    #statements
    echo "- [Search by $s"  >> $data_file
  done
}

function create_mru() {
  #statements
  local data=$1

  local LANG=`echo $REPO_NAME | awk -F'-' '{print $1}' `

  local PLATFORM=`echo $REPO_NAME | awk -F'-' '{print $2}' `

  local SPECIFIC=""

  local GENERAL=""

  local URL="(https://github.com/bearddan2000?tab=repositories&q=;;&type=&language=&sort=)"

  for d in `echo $data | sed 's/["|,]//g' | awk '{print $0}'`; do
    local search_url=`echo $URL | sed "s/;;/$d/g"`
    if [[ $d != "$LANG" && $d != "$PLATFORM" ]]; then
      #statements
      local special_url=`echo $search_url | sed "s/$d/$LANG-$PLATFORM-$d/g"`
      SPECIFIC="${SPECIFIC} ${d}]$special_url"
    fi

    GENERAL="${GENERAL} ${d}]$search_url"
  done

  write_search_to_file "$SPECIFIC" "## $LANG-$PLATFORM specific"

  write_search_to_file "$GENERAL" "## General"

}
function create_topics() {
  #statements
  local data_file=README.md

  # read first line
  local first_line=`cat ${data_file} | perl -e '@arr = <STDIN>; $line = $arr[0]; $line =~ s/[# |-]/ /g; print $line;'`

  # read the tech stack
  local first_pass=`cat ${data_file} | perl -0777 -ne '/## Tech stack\n([^#]*)/ && print +(split /[\n]{2,}/, $1)[0];' | awk -F '- ' '{I=sprintf("%s %s", I, $NF);}END{print I;}' | sed -e 's/^ //'`

  # read project title
  local second_pass=`echo $REPO_NAME | sed 's/-/ /g' `

  local third_pass=`echo ${first_line} ${first_pass} ${second_pass} | ruby -e 'puts gets.split.uniq.map { |e| %Q[ "#{e}", ]}'`

  third_pass=`echo $third_pass  | sed 's/,$//g'`


  create_mru "$third_pass"
}

for d in `ls -la | grep ^d | awk '{print $NF}' | egrep -v '^\.'`; do
    cd "$d"

    #`cat README.md | perl -0777 -ne '/## Description\n([^#]*)/ && print +(split /[\n]{2,}/, $1)[0];'`
    REPO_NAME=`head -n 1 README.md | sed 's/# //g'`

    create_topics

    cd ../
done
