const http = require('node:http');

const PORT = Number(process.env.PORT || 3000);
const syncedLogs = new Map();

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json'
  });
  response.end(JSON.stringify(body));
}

function readJson(request) {
  return new Promise((resolve, reject) => {
    let body = '';

    request.on('data', (chunk) => {
      body += chunk;
      if (body.length > 5_000_000) {
        reject(new Error('Payload too large'));
        request.destroy();
      }
    });

    request.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (error) {
        reject(error);
      }
    });

    request.on('error', reject);
  });
}

function validateLog(log) {
  return (
    log &&
    typeof log.id === 'string' &&
    typeof log.species === 'string' &&
    Number.isFinite(log.latitude) &&
    Number.isFinite(log.longitude) &&
    Number.isInteger(log.count) &&
    log.count > 0 &&
    typeof log.notes === 'string' &&
    Array.isArray(log.photoNames)
  );
}

const server = http.createServer(async (request, response) => {
  if (request.method === 'OPTIONS') {
    sendJson(response, 204, {});
    return;
  }

  if (request.method === 'GET' && request.url === '/health') {
    sendJson(response, 200, { ok: true, syncedCount: syncedLogs.size });
    return;
  }

  if (request.method === 'GET' && request.url === '/api/logs') {
    sendJson(response, 200, { logs: Array.from(syncedLogs.values()) });
    return;
  }

  if (request.method === 'POST' && request.url === '/api/logs/sync') {
    try {
      const payload = await readJson(request);
      const logs = Array.isArray(payload.logs) ? payload.logs : [];
      const acceptedLogs = logs.filter(validateLog);

      for (const log of acceptedLogs) {
        syncedLogs.set(log.id, {
          ...log,
          syncedAt: new Date().toISOString()
        });
      }

      sendJson(response, 200, {
        accepted: acceptedLogs.length,
        rejected: logs.length - acceptedLogs.length,
        syncedIds: acceptedLogs.map((log) => log.id)
      });
    } catch (error) {
      sendJson(response, 400, { error: 'Invalid sync payload' });
    }
    return;
  }

  sendJson(response, 404, { error: 'Route not found' });
});

server.listen(PORT, () => {
  console.log(`Field Log API listening on http://localhost:${PORT}`);
});
