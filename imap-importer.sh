#!/bin/sh

set -eu

REPORT_PATH="/imapbox"

attachment-downloader \
  --host "$DMARC_VIEWER_IMAP_HOST" \
  --username "$DMARC_VIEWER_IMAP_USER" \
  --password "$DMARC_VIEWER_IMAP_PASS" \
  --imap-folder "$DMARC_VIEWER_IMAP_FOLDER" \
  --output "$REPORT_PATH"

find "$REPORT_PATH" -type f -iname '*.zip' \
  -exec unzip -q '{}' -n -d "$REPORT_PATH" \;
find "$REPORT_PATH" -type f -iname '*.gz' \
  -exec gunzip -q -f -k {} \;

rm -f "$REPORT_PATH/None"

python manage.py parse --type in "$REPORT_PATH"

rm -f "$REPORT_PATH/*.xml"
