window.RUNTIME_CONFIG = Object.assign(window.RUNTIME_CONFIG || {}, {
  SUPABASE_URL: window.SUPABASE_URL || '',
  SUPABASE_ANON_KEY: window.SUPABASE_ANON_KEY || ''
});
Object.entries(window.RUNTIME_CONFIG).forEach(([key, value]) => {
  if (typeof value === 'string' && value) window[key] = value;
});
