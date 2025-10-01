/// Remove marcações de código (```json ... ```) para permitir parsing correto
String sanitizeJson(String raw) {
  var sanitized = raw.trim();
  if (sanitized.startsWith('```json')) sanitized = sanitized.substring(7).trim();
  if (sanitized.endsWith('```')) sanitized = sanitized.substring(0, sanitized.length - 3).trim();
  return sanitized;
}