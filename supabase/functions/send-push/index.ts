// send-push — relaie les inserts de `notifications` vers FCM (HTTP v1).
// Auth : header x-webhook-secret comparé à PUSH_WEBHOOK_SECRET (pas de JWT,
// l'appelant est le trigger Postgres via pg_net).
// Secrets requis : PUSH_WEBHOOK_SECRET, FCM_SERVICE_ACCOUNT (JSON compte de service Firebase).
import { createClient } from "npm:@supabase/supabase-js@2";

function b64url(input: string): string {
  return btoa(input).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function getAccessToken(sa: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const unsigned =
    b64url(JSON.stringify({ alg: "RS256", typ: "JWT" })) +
    "." +
    b64url(
      JSON.stringify({
        iss: sa.client_email,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
      }),
    );
  const keyData = sa.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt =
    unsigned + "." + b64url(String.fromCharCode(...new Uint8Array(sig)));
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=${encodeURIComponent("urn:ietf:params:oauth:grant-type:jwt-bearer")}&assertion=${jwt}`,
  });
  const json = await res.json();
  if (!json.access_token) throw new Error(`oauth: ${JSON.stringify(json)}`);
  return json.access_token;
}

Deno.serve(async (req: Request) => {
  const secret = Deno.env.get("PUSH_WEBHOOK_SECRET");
  if (!secret || req.headers.get("x-webhook-secret") !== secret) {
    return new Response("unauthorized", { status: 401 });
  }

  const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!saRaw) {
    // Firebase pas encore configuré — no-op propre.
    return new Response(JSON.stringify({ skipped: "no FCM_SERVICE_ACCOUNT" }), {
      status: 200,
    });
  }

  const { record } = await req.json();
  if (!record?.user_id) return new Response("no record", { status: 400 });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data: profile } = await supabase
    .from("profiles")
    .select("fcm_token")
    .eq("id", record.user_id)
    .maybeSingle();
  const token = profile?.fcm_token;
  if (!token) {
    return new Response(JSON.stringify({ skipped: "no token" }), {
      status: 200,
    });
  }

  const sa = JSON.parse(saRaw);
  const accessToken = await getAccessToken(sa);
  const dataPayload = record.data && typeof record.data === "object"
    ? Object.fromEntries(
        Object.entries(record.data).map(([k, v]) => [k, String(v)]),
      )
    : {};
  const fcmRes = await fetch(
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title: record.title, body: record.body },
          data: dataPayload,
        },
      }),
    },
  );

  // Token expiré/désinstallé → on le purge pour ne plus réessayer.
  if (fcmRes.status === 404 || fcmRes.status === 410) {
    await supabase
      .from("profiles")
      .update({ fcm_token: null })
      .eq("id", record.user_id);
  }

  return new Response(JSON.stringify({ fcm_status: fcmRes.status }), {
    status: 200,
  });
});
