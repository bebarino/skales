#!/bin/sh

git checkout -q clk-next &&
git reset -q --hard clk/master &&
git log --oneline clk/master..clk/clk-next --merges --reverse --grep="into clk-next" --pretty="%s" |
sed -ne "
	/^Merge branch 'clk-fixes'/d  # Ignore clk-fixes branches
	s/^Merge branch '\(clk-.*\)' .*/\1/p # But otherwise handle clk branches
	" |
{
	i=0
	branches=

	while read br
	do
		branches="$branches$br "
		i=$(($i + 1))
		if test $i -eq 5
		then
			echo git merge $branches
			i=0
			branches=
		fi
	done
	if test $i -gt 0
	then
		echo git merge $branches
	fi
}
