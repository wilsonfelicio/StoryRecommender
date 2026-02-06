export const dynamic = "force-dynamic";

export async function GET() {
  const key = process.env.BUILTIN_ANTHROPIC_KEY;
  const hasBuiltInKey = !!(key && key.length > 10);

  return Response.json({ hasBuiltInKey });
}
