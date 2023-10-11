addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event.request));
});

function objectToBase64url(payload) {
  return arrayBufferToBase64Url(
    new TextEncoder().encode(JSON.stringify(payload))
  );
}

function arrayBufferToBase64Url(buffer) {
  return btoa(String.fromCharCode(...new Uint8Array(buffer)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

const GOOGLE_KEY_HEADER = objectToBase64url({
  alg: "RS256",
  typ: "JWT",
});

async function handleRequest(request) {
  try {
    let url = new URL(request.url);
    const filepath = url.pathname.replace("/storage", "");
    if (filepath.length < 3) {
      return new Response(`path too short ${filepath}`, {
        status: 401,
        headers: { "content-type": "text/plain" },
      });
    }

    const iat = Math.round(Date.now() / 1000);
    const exp = iat + 3600;

    const claimset = objectToBase64url({
      iss: ISS,
      scope: "https://www.googleapis.com/auth/devstorage.read_write",
      aud: "https://www.googleapis.com/oauth2/v4/token",
      exp,
      iat,
    });

    const JWK = {
      kty: "RSA",
      n: JWKN,
      e: JWKE,
      d: JWKD,
      p: JWKP,
      q: JWKQ,
      dp: JWKDP,
      dq: JWKDQ,
      qi: JWKQI,
    };

    const key = await crypto.subtle.importKey(
      "jwk",
      JWK,
      {
        name: "RSASSA-PKCS1-v1_5",
        hash: {
          name: "SHA-256",
        },
      },
      false,
      ["sign"]
    );

    const rawToken = await crypto.subtle.sign(
      { name: "RSASSA-PKCS1-v1_5" },
      key,
      new TextEncoder().encode(`${GOOGLE_KEY_HEADER}.${claimset}`)
    );

    const token = arrayBufferToBase64Url(rawToken);

    const authResponse = await fetch(
      "https://www.googleapis.com/oauth2/v4/token",
      {
        method: "POST",
        headers: new Headers({
          "Content-Type": "application/json",
        }),
        body: JSON.stringify({
          grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
          assertion: `${GOOGLE_KEY_HEADER}.${claimset}.${token}`,
        }),
      }
    );

    const oauth = await authResponse.json();

    const bucketRequest = new Request(
      `https://storage.googleapis.com/${BUCKET_NAME}${filepath}`,
      {
        headers: new Headers({
          Authorization: `${oauth.token_type} ${oauth.access_token}`,
        }),
      }
    );

    const bucketResponse = await fetch(bucketRequest, {
      cf: {
        cacheTtlByStatus: { "200-299": 86400, 404: 1, "500-599": 0 },
        cacheEverything: true,
      },
    });
    const response = new Response(bucketResponse.body, bucketResponse);
    response.headers.set("Cache-Control", "max-age=86400");
    return response;
  } catch (error) {
    return new Response(error, {
      status: 401,
      headers: { "content-type": "text/plain" },
    });
  }
}
