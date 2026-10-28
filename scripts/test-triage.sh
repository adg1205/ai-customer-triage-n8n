#!/usr/bin/env bash
# Bash / cURL Test Script for n8n AI Customer Triage Engine

WEBHOOK_URL="${1:-http://localhost:5678/webhook/triage}"
PAYLOAD_FILE="${2:-../test-payloads/01-billing-urgent.json}"

echo "=========================================================="
echo " 🚀 n8n Customer Triage Engine - Webhook Integration Test"
echo "=========================================================="

if [ ! -f "$PAYLOAD_FILE" ]; then
  echo "Error: Payload file not found: $PAYLOAD_FILE"
  exit 1
fi

echo "Target Webhook : $WEBHOOK_URL"
echo "Payload File   : $PAYLOAD_FILE"
echo ""

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD_FILE" \
  -w "\n\nHTTP Status: %{http_code} | Total Time: %{time_total}s\n" \
  | jq . 2>/dev/null || cat

