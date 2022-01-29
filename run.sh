#!/bin/bash

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
    SUCCESS="successfully"
else
    echo "-- FAILED --"
    SUCCESS="with an error"
fi

### Formatting output data ###
if [ ${#OUTPUT} -gt ${MAX_OUTPUT_LENGTH} ]; then
    OUTPUT="...${OUTPUT:(-(${MAX_OUTPUT_LENGTH}-3))}"
fi

if [ "$OUTPUT" != "" ]; then
    OUTPUT="<b><u>Output:</u></b>
<pre>${OUTPUT}</pre>"
else
    OUTPUT="No output."
fi

### Execution time formatting ###
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
MESSAGE="Command \"<code>${COMMAND}</code>\" has completed <i><u>${SUCCESS}</u></i>.
<b>Execution time:</b> ${EXECUTION_TIME}
${OUTPUT}"

curl -s -X POST "${URL}" -d chat_id="${USER_ID}" -d text="${MESSAGE}" -d parse_mode=HTML > /dev/null
exit 0
