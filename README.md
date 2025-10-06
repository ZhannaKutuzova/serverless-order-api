
# Serverless Order API — Step 1 (Hello Endpoint)

Minimal, cheap demo: **Lambda (Node.js 20) + HTTP API**. No DynamoDB/SQS yet.
Goal: deploy POST `/order` that returns `{ ok: true }` and echoes payload.

## Prereqs
- AWS account with credentials configured locally (e.g. `aws configure sso` or `aws configure`).
- Terraform 1.5+.

## Deploy
```bash
cd infra
terraform init
terraform apply -auto-approve
```
Terraform will output the base URL.

Test:
```bash
API="$(terraform output -raw api_base_url)"
curl -s -X POST "$API/order" -H "content-type: application/json" -d '{"item":"test"}' | jq .
```

Expected:
```json
{ "ok": true, "ts": "...", "echo": { "item": "test" } }
```

## Clean up
```bash
cd infra
terraform destroy -auto-approve
```

## Next steps (Step 2)
- Add DynamoDB table `orders` (PAY_PER_REQUEST) and write from Lambda.
- Add SQS + DLQ for async processing.
- Wire GitHub Actions **OIDC** pipeline for `plan/apply` per env.
- Add CloudWatch alarms & basic dashboard.
