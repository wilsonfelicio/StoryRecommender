import { NextRequest } from "next/server";
import { buildProviderRequest, parseSSEDelta } from "@/lib/providers";
import { buildUserPrompt, SYSTEM_PROMPT } from "@/lib/prompts";
import { LLMProvider, StoryPreferences } from "@/lib/types";

export async function POST(req: NextRequest) {
  const {
    provider,
    apiKey: userApiKey,
    preferences,
  }: {
    provider: LLMProvider;
    apiKey: string;
    preferences: StoryPreferences;
  } = await req.json();

  // Use user key if provided, otherwise fall back to built-in Anthropic key
  let apiKey = userApiKey;
  if (!apiKey && provider === "anthropic") {
    apiKey = process.env.ANTHROPIC_API_KEY || "";
  }

  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "Missing API key" }),
      { status: 400, headers: { "Content-Type": "application/json" } }
    );
  }

  const userPrompt = buildUserPrompt(preferences);
  const { url, headers, body } = buildProviderRequest(
    provider,
    apiKey,
    SYSTEM_PROMPT,
    userPrompt
  );

  const upstream = await fetch(url, {
    method: "POST",
    headers,
    body,
  });

  if (!upstream.ok) {
    const errorText = await upstream.text();
    return new Response(
      JSON.stringify({ error: `Provider returned ${upstream.status}`, details: errorText }),
      { status: upstream.status, headers: { "Content-Type": "application/json" } }
    );
  }

  const reader = upstream.body?.getReader();
  if (!reader) {
    return new Response("No response stream", { status: 502 });
  }

  const decoder = new TextDecoder();
  const encoder = new TextEncoder();

  const stream = new ReadableStream({
    async start(controller) {
      let buffer = "";

      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          buffer += decoder.decode(value, { stream: true });
          const lines = buffer.split("\n");
          buffer = lines.pop() || "";

          for (const line of lines) {
            if (line.startsWith("data: ")) {
              const data = line.slice(6).trim();
              if (data === "[DONE]") continue;

              const text = parseSSEDelta(provider, data);
              if (text) {
                controller.enqueue(
                  encoder.encode(`data: ${JSON.stringify({ text })}\n\n`)
                );
              }
            }
          }
        }
      } catch (e) {
        controller.error(e);
      } finally {
        controller.close();
      }
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  });
}
