// lambda/handler.mjs
export const handler = async (event) => {
  let payload = null;
  try {
    const body = typeof event.body === "string" ? event.body : JSON.stringify(event.body || {});
    payload = body ? JSON.parse(body) : null;
  } catch {}
  return {
    statusCode: 200,
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ ok: true, ts: new Date().toISOString(), echo: payload }),
  };
};
