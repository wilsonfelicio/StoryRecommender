export async function GET() {
  const hasBuiltInKey = !!(
    process.env.ANTHROPIC_API_KEY &&
    process.env.ANTHROPIC_API_KEY.length > 10
  );

  return Response.json({ hasBuiltInKey });
}
