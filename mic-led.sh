#!/bin/bash

CODEC_DEVICE="/dev/snd/hwC1D0"

log() {
	echo "[$(date '+%H:%M:%S')] $*" >>/tmp/mic-led.log
}

led_on() {
	log "Turning LED ON"
	sudo hda-verb "$CODEC_DEVICE" 0x01 SET_GPIO_MASK 0x16
	sudo hda-verb "$CODEC_DEVICE" 0x01 SET_GPIO_DIR 0x16
	sudo hda-verb "$CODEC_DEVICE" 0x01 SET_GPIO_DATA 0x00
}

led_off() {
	log "Turning LED OFF"
	sudo hda-verb "$CODEC_DEVICE" 0x01 SET_GPIO_DATA 0x04
}

get_default_source_id() {
	wpctl status | sed -n '/^Audio$/,/^Video$/p' | sed -n '/├─ Sources:/,/├─ Filters:/p' | grep -E "^\s*│\s+\*\s+[0-9]+\." | sed 's/.*\*\s*\([0-9]*\)\..*/\1/'
}

update_led() {
	SOURCE_ID=$(get_default_source_id)
	log "Default source ID: $SOURCE_ID"

	if [ -z "$SOURCE_ID" ]; then
		log "ERROR: Could not get default source ID"
		return
	fi

	MUTE_STATUS=$(wpctl get-volume $SOURCE_ID)
	log "Mute status: $MUTE_STATUS"

	if echo "$MUTE_STATUS" | grep -q "\[MUTED\]"; then
		led_on
	else
		led_off
	fi
}

log "Starting mic-led"
update_led

while true; do
	sleep 1
	update_led
done
