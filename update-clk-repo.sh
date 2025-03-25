#!/bin/sh
#
# Update the clk repo by pruning merged branches and moving
# clk-next and clk-fixes to point to the latest -rc1 tag.
#
# Typically this is run after -rc1 comes out and before -rc2 so that
# we get the right rc tag
#

dry=
while test $# != 0
do
	case "$1" in
	--dry-run)
		dry=t
		;;
	esac
	shift
done

delete=
while read hash branch
do
	# Always seem to have an empty line at the end
	if test -z "$hash"
	then
		continue
	fi
	branch="${branch#refs\/heads\/}"
	merged=$(git branch --list -r linus/master --contains $hash)
	if test -n "$merged"
	then
		delete=":$branch $delete"
	fi

done <<< "$(git ls-remote --heads clk | \
	egrep -v -e '/clk-fixes$' -e '/clk-next$' -e '/master$')"

latest=$(git describe --abbrev=0 linus/master)

if test -n "$dry"
then
	echo git push clk $delete $latest^0:clk-fixes $latest^0:clk-next $latest^0:master
else
	git push clk $delete $latest^0:clk-fixes $latest^0:clk-next $latest^0:master || exit 1
fi

delete=
while read branch
do
	# Always seem to have an empty line at the end
	if test -z "$branch"
	then
		continue
	fi
	delete="$branch $delete"
done <<< "$(git branch --list "clk-*" --merged linus/master | \
	egrep -v -e 'clk-fixes$' -e 'clk-next$')"

if test -n "$delete"
then
	if test -n "$dry"
	then
		echo git branch -d $delete
	else
		git branch -d $delete || exit 1
	fi
fi
