#! /usr/bin/env bash

# script source:
# https://bitbucket.org/dmn/scripts/src/tip/bbrepolist.sh

# by dmn

USER='dmn'
REPOSITORIES=
RAW=0

usage() {
	echo -e "Generate HTML page witch all public reposiories of given user.\n"
	echo -e "Usage examples:"
	echo -e "\t`basename $0` dmn > repositories.html"
	echo ""
	echo "Arguments:"
	echo -e "\tname  \tuser name"
	echo -e "\t--raw \tdo not use markdown processor"
	echo -e "\t--help\tshow short help"
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

while [ $# -gt 0 ]; do
	if [ "--help" == "$1" ]; then
		usage
		exit 1
	elif [ "--raw" == "$1" ]; then
		RAW=1
	else
		USER="$1"
		#echo "USER: $USER"
	fi
	shift
done

if [ 0 == $RAW ]; then
	if [[ "" == "`which markdown`" ]]; then
		echo 'install markdown!'
		exit 3
	fi
fi

html_head() {
cat << EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="pl" xml:lang="pl">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link href="http://dmn.bitbucket.org/css/markdown.css" rel="stylesheet"></link>
	<link href="http://dmn.bitbucket.org/css/poole.css" rel="stylesheet"></link>
</head><body>
<div id="box">
<div id="header"><h1>${1}</h1></div>
<div id="content">
EOF
}

html_tail() {
cat << EOF
</div></div>
<div id="footer">Built with <a href="http://dmn.bitbucket.org">Bitbucket Repository Lister</a></div>
</body></html>
EOF
}

xml_bitbucket_reset() {
	scm=
	owner=
	website=
	description=
	slug=
	name=
	language=
	utc_last_updated=
	resource_uri=
}

xml_to_md() {
	if [ "${name}" == "" ]; then
		exit
	fi

	REPOURL="https://bitbucket.org/${USER}/${name}"
	READMEURL="${REPOURL}/raw/tip/README.md"

	echo -ne "${name}\n---\n\n"
	if [ "${description}" != "" ]; then
		echo -ne "${description}\n\n"
	fi
	echo -ne "**More information about ${name}**\n\n"
	if [ "${website}" != "" ]; then
		echo -ne " - [Project website](${website}),\n"
	fi

	READMECODE=`curl -s -o /dev/null -I -w "%{http_code}" $READMEURL`
	if [ "$READMECODE" -eq "200" ] ; then
		#echo OK
		READMEFILE="README-${name}.html"
		if [ 1 == $RAW ]; then
			curl -s "$READMEURL" > "${READMEFILE}"
		else
			html_head "$name readme" > "${READMEFILE}"
			curl -s "$READMEURL" | markdown >> "${READMEFILE}"
			html_tail >> "${READMEFILE}"
		fi

		echo -ne " - [Readme](${READMEFILE}),\n"
	fi

	echo -ne " - [Bitbucket](${REPOURL}),\n"
	echo -ne " - [Source code](${REPOURL}/src) (last updated: ${utc_last_updated}).\n\n"
	echo -ne "\n\n\n\n"
	xml_bitbucket_reset
}

xml_read_dom() {
	local IFS=\>
	read -d \< ENTITY CONTENT
	local RET=$?
	TAG_NAME=${ENTITY%% *}
	ATTRIBUTES=${ENTITY#* }
	return $RET
}

xml_parse_dom() {
	if [[ "$TAG_NAME" = "scm" ]]; then
		scm="$CONTENT"
	elif [[ "$TAG_NAME" = "owner" ]]; then
		owner="$CONTENT"
	elif [[ "$TAG_NAME" = "website" ]]; then
		website="$CONTENT"
	elif [[ "$TAG_NAME" = "description" ]]; then
		description="$CONTENT"
	elif [[ "$TAG_NAME" = "slug" ]]; then
		slug="$CONTENT"
	elif [[ "$TAG_NAME" = "name" ]]; then
		name="$CONTENT"
	elif [[ "$TAG_NAME" = "language" ]]; then
		language="$CONTENT"
	elif [[ "$TAG_NAME" = "utc_last_updated" ]]; then
		utc_last_updated="$CONTENT"
	elif [[ "$TAG_NAME" = "resource_uri" ]]; then
		resource_uri="$CONTENT"
		xml_to_md
	fi
	#eval local $ATTRIBUTES
	#echo "$website"
}

xml_do_dom() {
	while xml_read_dom; do
		xml_parse_dom
	done
}

make_repositories() {
	curl -s "https://api.bitbucket.org/1.0/users/${USER}/?format=xml" | xml_do_dom
}

if [ 1 == $RAW ]; then
	make_repositories
else
	html_head "${USER} repositories"
	make_repositories | markdown
	html_tail
fi

exit 0

