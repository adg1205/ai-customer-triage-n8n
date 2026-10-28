# PowerShell Test Script for n8n AI Customer Triage Engine
param(
    [string]$WebhookUrl = "http://localhost:5678/webhook/triage",
    [string]$PayloadFile = "../test-payloads/01-billing-urgent.json"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🚀 n8n Customer Triage Engine - Webhook Integration Test" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not (Test-Path $PayloadFile)) {
    Write-Error "Payload file not found: $PayloadFile"
    exit 1
}

$payloadJson = Get-Content -Raw -Encoding utf8 -Path $PayloadFile
Write-Host "`nTarget URL : $WebhookUrl" -ForegroundColor Yellow
Write-Host "Payload File : $PayloadFile" -ForegroundColor Yellow
Write-Host "`nSending inbound customer payload..." -ForegroundColor Gray

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($payloadJson)) -ContentType "application/json; charset=utf-8"
    $stopwatch.Stop()

    Write-Host "`n Status: HTTP 200 OK (Elapsed: $($stopwatch.ElapsedMilliseconds) ms)" -ForegroundColor Green
    Write-Host "`nStructured Dispatch Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
}
catch {
    Write-Host "`n Request Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor DarkRed
    }
}

