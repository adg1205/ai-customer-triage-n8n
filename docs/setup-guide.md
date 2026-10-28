# Step-by-Step Setup & Deployment Guide

This guide will walk you through running the project locally, importing the workflow, setting up credentials, and running your first test.

---

## Prerequisites

Choose **one** of the following runtime environments:
- **Option A (No Docker needed - Fastest)**: [Node.js 18+](https://nodejs.org/) (already installed on your machine!)
- **Option B**: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (requires WSL2 on Windows)
- **Option C**: [n8n Cloud Free Account](https://n8n.io/cloud/)

External accounts needed:
- A [Google AI Studio](https://aistudio.google.com/) account for a free Gemini API key.
- A Slack workspace with permissions to create an Incoming Webhook (or Discord).
- A Google account (for Google Sheets & Gmail OAuth credentials).

---

## Step 1: Start n8n

### Option A: Direct Node.js / npx (No Docker Required)

Since Node.js is installed on your machine, you can run n8n directly:

```powershell
npx n8n
```
*Or install globally once:*
```powershell
npm install -g n8n
n8n start
```

Once running, navigate to:
```
http://localhost:5678
```

---

### Option B: Using Docker Compose

If you have Docker Desktop installed and running:

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Launch n8n via Docker Compose:
   ```bash
   docker compose -f docker/docker-compose.yml up -d
   ```

3. Open your browser and navigate to:
   ```
   http://localhost:5678
   ```

---

## Step 2: Import the Workflow into n8n

1. In the n8n UI, click **Workflows** in the left sidebar.
2. Click the **+ Add Workflow** or **...** (three dots menu at top right).
3. Select **Import from File**.
4. Choose `workflow/AI_Customer_Triage.json` from this repository.
5. You will see the entire 10-node pipeline rendered on the canvas.

---

## Step 3: Configure External Credentials

### 1. Google Gemini API
- Go to [Google AI Studio](https://aistudio.google.com/app/apikey) and generate an API key.
- Open the node **Gemini AI Classification**.
- Set the header `x-goog-api-key` to your API key (or set `GEMINI_API_KEY` in your `.env` file).

### 2. Slack Incoming Webhook
- In Slack, go to **Manage Apps** → **Custom Integrations** → **Incoming Webhooks**.
- Select a channel (e.g. `#urgent-tickets` or `#support-escalations`).
- Copy the Webhook URL (format: `https://hooks.slack.com/services/...`).
- Open the node **Dispatch Instant Slack Escalation** and paste the webhook URL into the `URL` parameter.

### 3. Google Sheets (CRM)
- Create a new Google Spreadsheet named `Customer Triage Tickets`.
- Add the following header row to Sheet 1:
  ```
  Ticket ID | Timestamp | Customer ID | Customer Name | Email | Channel | Subject | Intent | Urgency | Sentiment | Issue Summary | Product Area | Drafted Reply | Routing Reason | Status | Priority | Dispatched Via
  ```
- In n8n, double-click **Sync Ticket to Google Sheets CRM**.
- Connect your Google account using n8n's Google Sheets OAuth2 credential flow.
- Select your spreadsheet from the dropdown.

### 4. Gmail (Automated Customer Acknowledgment)
- Double-click **Send Automated Customer Acknowledgment Email**.
- Connect your Gmail account using the Gmail OAuth2 credential flow.
- (Optional: for testing, you can use your own email address as recipient).

---

## Step 4: Activate the Webhook & Test

1. Click **Save** in the top right corner.
2. Toggle the workflow to **Active** (or click **Test step** / **Listen for test event**).
3. Open a terminal and run the test script:

**On Windows (PowerShell):**
```powershell
./scripts/test-triage.ps1 -PayloadFile ./test-payloads/01-billing-urgent.json
```

**On Linux / macOS:**
```bash
./scripts/test-triage.sh http://localhost:5678/webhook/triage test-payloads/01-billing-urgent.json
```

4. **Verify the Results**:
   - Check Slack: You should receive an instant alert for the billing dispute (`Urgency: 4`).
   - Check Google Sheets: A new row should be appended with all extracted entities.
   - Check Gmail Sent folder: An acknowledgment email was dispatched to the customer.
   - Terminal Output: You'll see a clean JSON response containing the generated `ticket_id`.

---

## Step 5: Troubleshooting

| Issue | Solution |
|---|---|
| **Webhook returns 404** | Make sure the workflow is activated, or click "Test step" inside the Webhook node for test mode. Note that test mode uses `/webhook-test/triage`. |
| **Gemini API returns 400 or 403** | Verify that your API key is valid and has access to `gemini-2.0-flash`. |
| **Google Sheets permission error** | Ensure the Google Cloud OAuth app has the `https://www.googleapis.com/auth/spreadsheets` scope enabled. |

