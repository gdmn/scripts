#! /usr/bin/env bash

# see https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

set -e

git_fetch() {
	local repo="$1"
	if [ ! -d "$repo/.git" ] ; then
		echo '.git directory not found'
		exit 1
	fi
	echo " :: $repo "
	pushd "$repo" >/dev/null
	git fetch --all || true
	popd >/dev/null
}

git_local_modified() {
	local repo="$1"
	echo -n " :: $repo "
	pushd "$repo" >/dev/null
	local is_mod=false
	local is_pull=false
	if git diff-index --quiet HEAD -- ; then
		echo -n ''
	else
		is_mod=true
		echo -n ' :: MOD '
	fi
	if git rev-parse @{u} >/dev/null 2>&1 ; then
		local LOCAL="$(git rev-parse HEAD 2>/dev/null)"
		local REMOTE="$(git rev-parse @{u} 2>/dev/null)"
		local BASE="$(git merge-base HEAD @{u} 2>/dev/null)"
		#echo "LOCAL=$LOCAL REMOTE=$REMOTE BASE=$BASE"

		if [[ $LOCAL == $REMOTE ]]; then
			echo -n " :: Up-to-date "
		elif [[ $LOCAL == $BASE ]]; then
			is_pull=true
			echo -n ' :: PULL! '
		elif [[ $REMOTE == $BASE ]]; then
			echo -n " :: PUSH "
		else
			echo -n ":: Diverged "
		fi
	else
		echo -n ' :: NO-UPSTREAM-BRANCH '
	fi
	echo ''

	# echo "is_pull=$is_pull is_mod=$is_mod"
	if [[ $is_pull == true && $is_mod == false ]] ; then
		echo " :: trying to pull "
		git pull
	fi
	popd >/dev/null
}

find_repos() {
	local func="$1"
	local dest="$2"
	find "$dest" -name '.git' -type d \
		2>/dev/null | \
		grep -v '/.cache/' | \
		grep -v '/.vim/' | \
		while read k ; do
			dir="$(dirname $k)"
			echo "${dir}"
		done | \
		while read repo ; do
			$func "$repo"
		done
}

process() {
	local dir="$( cd -- "$1" &> /dev/null && pwd )"
	echo "destination directory: $dir"
	find_repos git_fetch "$dir"
	find_repos git_local_modified "$dir"
}

if [[ "$1" == "--help" ]]; then
	echo 'no help yet'
elif [ $# -eq 1 ]; then
	process "$1"
else
	process .
fi

exit 0
