#!/bin/bash

set -o nounset
set -o errexit

MSGFILE="commit-msg.txt"

SUBJECT="$@"
if [[ -n "$SUBJECT" ]]; then
	echo "$SUBJECT" > "$MSGFILE"
	echo >> "$MSGFILE"
	echo >> "$MSGFILE"
else
	rm -f "$MSGFILE"
fi

git submodule summary | grep -e '^\*' | while read SUBMODULE; do
	PROJECT=$(echo "$SUBMODULE" | sed -e 's/^\*\s\+\(\S\+\).*/\1/')
	CRANGE=$(echo "$SUBMODULE" | sed -e 's/^\*\s\+\S\+\s\+\(\S\+\).*/\1/' | sed -e 's/^0\+\.\.\.//')
	echo "$SUBMODULE"
	pushd "$PROJECT" &>/dev/null
	echo "$SUBMODULE" >> ../"$MSGFILE"
	echo >> ../"$MSGFILE"
	git log "$CRANGE" | grep -ve '^Author:\|Date:\|Merge:' | sed -e 's/\(.*\)/    \1/' >> ../"$MSGFILE"
	echo >> ../"$MSGFILE"
	echo >> ../"$MSGFILE"
	popd &>/dev/null
done
