#!/bin/bash

### Check if a command argument is provided ###
if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

source "$(dirname "$(realpath "$0")")"/.env.local || exit 1

MAX_OUTPUT_LENGTH=250

COMMAND="$*"

### Executing command ###
START_TIME=$(date +"%s.%N")
OUTPUT=$({ ${COMMAND} && echo "-- SUCCESS --"; } 2>&1 | tee /dev/tty)
EXECUTION_TIME=$(echo "$(date +"%s.%N")" - "${START_TIME}" | bc)

### Extracting exit code ###
if [ "${OUTPUT:(-13)}" = "-- SUCCESS --" ]; then
    OUTPUT="${OUTPUT%$'\n'*}"
    SUCCESS="Completed"
else
    echo "-- FAILED --"
    SUCCESS="Failed"
fi

### Formatting output data ###
if [ ${#OUTPUT} -gt ${MAX_OUTPUT_LENGTH} ]; then
    OUTPUT="...${OUTPUT:(-(${MAX_OUTPUT_LENGTH}-3))}"
fi

if [ "$OUTPUT" != "" ]; then
    ESCAPED_OUTPUT=$(echo "$OUTPUT" | sed -e 's/</\%26lt;/g' -e 's/>/\%26gt;/g' -e 's/&/\%26amp;/g') # %26 for &

    OUTPUT="<b>Output:</b>
<pre>${ESCAPED_OUTPUT}</pre>"
else
    OUTPUT="No output."
fi

### Formatting the time ###
EXECUTION_TIME=$(printf %.3f "$EXECUTION_TIME")
MILLISECONDS=${EXECUTION_TIME:(-3)}
EXECUTION_TIME=${EXECUTION_TIME%$'.'*}

HOURS=$((EXECUTION_TIME / 3600))
MINUTES=$((EXECUTION_TIME % 3600 / 60))
SECONDS=$((EXECUTION_TIME % 60))

EXECUTION_TIME=""

if [ $HOURS -ne 0 ]; then
    EXECUTION_TIME="${HOURS}h "
fi

if [ $HOURS -ne 0 ] || [ $MINUTES -ne 0 ]; then
    EXECUTION_TIME="${EXECUTION_TIME}${MINUTES}m "
fi

EXECUTION_TIME="${EXECUTION_TIME}${SECONDS}s ${MILLISECONDS}ms"

### Sending notification ###
URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

MESSAGE="<b>Command:</b> <code>${COMMAND}</code>
<b>Status:</b> ${STATUS}
<b>Execution time:</b> ${EXECUTION_TIME}

${OUTPUT}"

curl -s -X POST "${URL}" -d chat_id="${USER_ID}" -d text="${MESSAGE}" -d parse_mode=HTML > /dev/null
exit 0
