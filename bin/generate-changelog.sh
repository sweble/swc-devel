#!/bin/bash
#
# Copyright 2011 The Open Source Research Group,
#                University of Erlangen-Nürnberg
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


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
