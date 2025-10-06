import os, json, time, uuid
import boto3
from decimal import Decimal

TABLE = os.environ.get("TABLE_NAME")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE)

CORS_HEADERS = {
    "access-control-allow-origin": "*",
    "access-control-allow-headers": "content-type,authorization",
    "access-control-allow-methods": "GET,POST,OPTIONS",
}

def _to_jsonable(x):
    if isinstance(x, Decimal):
        return int(x) if x % 1 == 0 else float(x)
    if isinstance(x, list):
        return [_to_jsonable(i) for i in x]
    if isinstance(x, dict):
        return {k: _to_jsonable(v) for k, v in x.items()}
    return x

def _json(body, code=200, headers=None):
    h = {"content-type": "application/json", **CORS_HEADERS}
    if headers: h.update(headers)
    return {"statusCode": code, "headers": h, "body": json.dumps(_to_jsonable(body))}

def _no_content():
    return {"statusCode": 204, "headers": CORS_HEADERS, "body": ""}

def handler(event, context):
    http = (event.get("requestContext") or {}).get("http") or {}
    method = http.get("method")
    raw_path = event.get("rawPath") or http.get("path") or ""
    path_params = event.get("pathParameters") or {}

    # OPTIONS preflight → просто отвечаем 204
    if method == "OPTIONS":
        return _no_content()

    # POST /order  -> create
    if method == "POST" and (raw_path.endswith("/order") or http.get("path","").endswith("/order")):
        body = event.get("body")
        try:
            payload = json.loads(body) if isinstance(body, str) else (body or {})
        except Exception:
            payload = {}
        item = {"pk": str(uuid.uuid4()), "ts": int(time.time()), "payload": payload}
        table.put_item(Item=item)
        return _json({"ok": True, "id": item["pk"], "ts": item["ts"]})

    # GET /order/{id} -> read
    if method == "GET":
        order_id = path_params.get("id")
        if not order_id and "/order/" in raw_path:
            order_id = raw_path.split("/order/", 1)[-1].split("?", 1)[0]
        if not order_id:
            return _json({"ok": False, "error": "missing id"}, 400)

        resp = table.get_item(Key={"pk": order_id})
        item = resp.get("Item")
        if not item:
            return _json({"ok": False, "error": "not found"}, 404)
        return _json({"ok": True, "item": item})

    return _json({"ok": False, "error": "route not found"}, 404)
