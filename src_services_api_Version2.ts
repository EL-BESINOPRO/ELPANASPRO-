export async function fetchApps() {
  const res = await fetch('/apps.json', {cache: "no-store"});
  if (!res.ok) return [];
  return res.json();
}