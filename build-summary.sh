#!/bin/sh

git --no-pager log linus/master..clk-next --merges | grep -A3 ' - '
echo
git --no-pager log linus/master..clk-next --merges
echo
git --no-pager log --oneline linus/master..clk-next --no-merges
echo
git --no-pager diff linus/master...clk-next --stat --summary --dirstat
echo
git --no-pager shortlog linus/master..clk-next
