import { LLMProvider, PROVIDERS } from "./types";

export function getProviderConfig(provider: LLMProvider) {
  return PROVIDERS.find((p) => p.value === provider)!;
}

export function buildProviderRequest(
  provider: LLMProvider,
  apiKey: string,
  systemPrompt: string,
  userPrompt: string
): { url: string; headers: Record<string, string>; body: string } {
  const config = getProviderConfig(provider);

  switch (provider) {
    case "anthropic":
      return {
        url: "https://api.anthropic.com/v1/messages",
        headers: {
          "Content-Type": "application/json",
          "anthropic-version": "2023-06-01",
          "x-api-key": apiKey,
        },
        body: JSON.stringify({
          model: config.defaultModel,
          max_tokens: 4096,
          stream: true,
          system: systemPrompt,
          messages: [{ role: "user", content: userPrompt }],
        }),
      };

    case "openai":
      return {
        url: "https://api.openai.com/v1/chat/completions",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: config.defaultModel,
          max_tokens: 4096,
          stream: true,
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
        }),
      };

    case "gemini":
      return {
        url: `https://generativelanguage.googleapis.com/v1beta/models/${config.defaultModel}:streamGenerateContent?alt=sse&key=${apiKey}`,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: userPrompt }] }],
          systemInstruction: { parts: [{ text: systemPrompt }] },
          generationConfig: { maxOutputTokens: 4096 },
        }),
      };
  }
}

export function parseSSEDelta(
  provider: LLMProvider,
  data: string
): string | null {
  if (data === "[DONE]") return null;

  try {
    const json = JSON.parse(data);

    switch (provider) {
      case "anthropic": {
        if (
          json.type === "content_block_delta" &&
          json.delta?.type === "text_delta"
        ) {
          return json.delta.text ?? null;
        }
        return null;
      }

      case "openai": {
        const content = json.choices?.[0]?.delta?.content;
        return content ?? null;
      }

      case "gemini": {
        const text =
          json.candidates?.[0]?.content?.parts?.[0]?.text;
        return text ?? null;
      }
    }
  } catch {
    return null;
  }
}
