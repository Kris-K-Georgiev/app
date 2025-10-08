// Simple fetch wrapper for admin SPA using session cookies.
const base = '/admin/api';

async function request(path, options = {}) {
  const resp = await fetch(base + path, {
    headers: {
      'Accept': 'application/json',
      'Content-Type': options.body instanceof FormData ? undefined : 'application/json',
      ...options.headers,
    },
    credentials: 'same-origin',
    method: options.method || 'GET',
    body: options.body instanceof FormData ? options.body : (options.body ? JSON.stringify(options.body) : undefined),
  });
  if (!resp.ok) {
    let message = resp.status + ' ' + resp.statusText;
    try { const data = await resp.json(); message = data.message || JSON.stringify(data); } catch(_) {}
    dispatchToast({ type:'error', message });
    throw new Error(message);
  }
  const ct = resp.headers.get('content-type') || '';
  if (ct.includes('application/json')) return resp.json();
  return resp.text();
}

// Simple toast event dispatcher
const listeners = [];
export function onToast(fn){ listeners.push(fn); }
function dispatchToast(t){ listeners.forEach(l=>{ try { l(t); } catch{} }); }

export const api = {
  metrics: () => request('/metrics'),
  users: (params={}) => request('/users'+query(params)),
  posts: (params={}) => request('/posts'+query(params)),
  prayers: (params={}) => request('/prayers'+query(params)),
  feedback: (params={}) => request('/feedback-items'+query(params)),
  updateFeedbackStatus: (id, body) => request(`/feedback-items/${id}/status`, { method:'PATCH', body }),
  // CRUD prefixed endpoints
  crud: {
    list: (res, params={}) => request(`/crud/${res}`+query(params)),
    show: (res, id) => request(`/crud/${res}/${id}`),
    create: (res, body) => request(`/crud/${res}`, { method:'POST', body }),
    update: (res, id, body) => request(`/crud/${res}/${id}`, { method:'PUT', body }),
    destroy: (res, id) => request(`/crud/${res}/${id}`, { method:'DELETE' }),
    restore: (res, id) => request(`/crud/${res}/${id}/restore`, { method:'PATCH' }),
  }
};

function query(obj){
  const q = Object.entries(obj).filter(([,v])=>v!==undefined&&v!==null&&v!=='').map(([k,v])=>encodeURIComponent(k)+'='+encodeURIComponent(v));
  return q.length?'?'+q.join('&'):'';
}
