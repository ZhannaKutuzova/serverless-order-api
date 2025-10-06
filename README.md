# Serverless Order API — AWS Lambda + Terraform

[![CI](https://github.com/ZhannaKutuzova/serverless-order-api/actions/workflows/ci.yml/badge.svg)](https://github.com/ZhannaKutuzova/serverless-order-api/actions)
![Terraform](https://img.shields.io/badge/Terraform-validated-7B42BC?logo=terraform)
![AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-nodejs20.x-orange?logo=awslambda)
![API Gateway](https://img.shields.io/badge/API%20Gateway-HTTP%20API-blue?logo=amazonapigateway)

Minimal, cost‑efficient serverless backend using **AWS Lambda (Node.js 20)** and **Amazon API Gateway (HTTP API)**.  
Infrastructure is fully defined with **Terraform**. The demo exposes a `POST /order` endpoint that returns a structured JSON response.

---

## 🧩 Tech Stack
- **AWS Lambda (nodejs20.x)** — compute  
- **Amazon API Gateway (HTTP API)** — public endpoint with CORS  
- **Terraform ≥ 1.5** — infrastructure as code  
- **AWS IAM** — least‑privilege execution role  
- **CloudWatch Logs** — basic monitoring  

---

## 🚀 Deploy

Requirements:
- AWS account + credentials (`aws configure sso` or `aws configure`)  
- Terraform ≥ 1.5

```bash
cd infra
terraform init
terraform apply -auto-approve
```
Terraform outputs:
```
api_base_url = "https://<api-id>.execute-api.<region>.amazonaws.com"
```

---

## 🧪 Test
```bash
API="$(terraform output -raw api_base_url)"

# Create an order (echo payload)
curl -s -X POST "$API/order"   -H 'content-type: application/json'   -d '{"item":"test"}' | jq .
```

Expected response:
```json
{
  "ok": true,
  "ts": 1730000000,
  "echo": { "item": "test" }
}
```

---

## 🧹 Clean up
```bash
cd infra
terraform destroy -auto-approve
```

---

## 💰 Cost (typical demo scale)
| Service              | Estimate / 1M requests |
|----------------------|------------------------|
| API Gateway (HTTP)   | ~$1.00                 |
| Lambda (req+dur)     | ~$0.20–0.30            |
| CloudWatch Logs      | ~$0.10–0.30            |

With light testing this is typically **well under $5/month**.  
(At scale, add DynamoDB/SQS costs.)

---

## 📈 Next Steps
- Add DynamoDB (on‑demand) to persist orders  
- Add SQS + DLQ for async processing  
- Wire GitHub Actions with **OIDC** for plan/apply  
- Add CloudWatch alarms & a small dashboard  

---

> This repository demonstrates AWS serverless fundamentals: Terraform IaC, a minimal HTTP API, and predictable low cost.
