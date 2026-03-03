#!/bin/bash

# audio-led - Audio Mute LED Controller for HP Envy with Realtek ALC245
# This script monitors PipeWire sink mute state and controls the LED via HDA GPIO

CODEC_DEVICE="/dev/snd/hwC1D0"

log() {
	:
}

led_on() {
	log "Turning LED ON"
	sudo hda-verb "$CODEC_DEVICE" 0x20 0x500 0x0b 2>&1
	sudo hda-verb "$CODEC_DEVICE" 0x20 0x400 0x08 2>&1
}

led_off() {
	log "Turning LED OFF"
	sudo hda-verb "$CODEC_DEVICE" 0x20 0x500 0x0b 2>&1
	sudo hda-verb "$CODEC_DEVICE" 0x20 0x400 0x00 2>&1
}

get_default_sink_id() {
	wpctl status | grep -E "^\s*│\s+\*\s+[0-9]+\." | head -1 | sed 's/.*\*\s*\([0-9]*\)\..*/\1/'
}

update_led() {
	SINK_ID=$(get_default_sink_id)
	log "Default sink ID: $SINK_ID"

	if [ -z "$SINK_ID" ]; then
		log "ERROR: Could not get default sink ID"
		return
	fi

	MUTE_STATUS=$(pactl get-sink-mute "$SINK_ID" 2>/dev/null)
	log "Mute status: $MUTE_STATUS"

	if echo "$MUTE_STATUS" | grep -q "Mute: yes"; then
		led_on
	else
		led_off
	fi
}

log "Starting audio-led"
update_led

while true; do
	sleep 1
	update_led
done
