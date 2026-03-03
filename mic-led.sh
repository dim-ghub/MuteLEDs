#!/bin/bash

CODEC_DEVICE="/dev/snd/hwC1D0"

log() {
	:
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
	wpctl status | grep -E "^\s*│\s+\*\s+[0-9]+\." | head -1 | sed 's/.*\*\s*\([0-9]*\)\..*/\1/'
}

update_led() {
	SOURCE_ID=$(get_default_source_id)
	log "Default source ID: $SOURCE_ID"

	if [ -z "$SOURCE_ID" ]; then
		log "ERROR: Could not get default source ID"
		return
	fi

	MUTE_STATUS=$(pactl get-source-mute "$SOURCE_ID" 2>/dev/null)
	log "Mute status: $MUTE_STATUS"

	if echo "$MUTE_STATUS" | grep -q "Mute: yes"; then
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
