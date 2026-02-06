"use client";

import { useState, useEffect } from "react";
import { LLMProvider, PROVIDERS } from "@/lib/types";
import {
  getSelectedProvider,
  setSelectedProvider,
  getApiKey,
  saveApiKey,
  deleteApiKey,
} from "@/lib/storage";

export default function SettingsPage() {
  const [provider, setProvider] = useState<LLMProvider>("anthropic");
  const [keyInput, setKeyInput] = useState("");
  const [message, setMessage] = useState<{ text: string; success: boolean } | null>(null);
  const [isTesting, setIsTesting] = useState(false);
  const [testResult, setTestResult] = useState<{ text: string; success: boolean } | null>(null);

  useEffect(() => {
    const p = getSelectedProvider();
    setProvider(p);
    loadKeyDisplay(p);
  }, []);

  const loadKeyDisplay = (p: LLMProvider) => {
    const key = getApiKey(p);
    if (key.length > 12) {
      setKeyInput(key.slice(0, 8) + "..." + key.slice(-4));
    } else {
      setKeyInput(key);
    }
    setMessage(null);
    setTestResult(null);
  };

  const handleProviderChange = (p: LLMProvider) => {
    setProvider(p);
    setSelectedProvider(p);
    loadKeyDisplay(p);
  };

  const handleSave = () => {
    if (keyInput.includes("...")) {
      setMessage({ text: "No changes made.", success: true });
      return;
    }
    saveApiKey(provider, keyInput);
    setMessage({
      text: keyInput ? "Key saved securely." : "Key removed.",
      success: true,
    });
  };

  const handleDelete = () => {
    deleteApiKey(provider);
    setKeyInput("");
    setMessage({ text: "Key removed.", success: true });
    setTestResult(null);
  };

  const handleTest = async () => {
    setIsTesting(true);
    setTestResult(null);

    const apiKey = getApiKey(provider);
    if (!apiKey) {
      setTestResult({ text: "No API key saved.", success: false });
      setIsTesting(false);
      return;
    }

    try {
      const res = await fetch("/api/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          provider,
          apiKey,
          preferences: {
            length: "short",
            mood: "calming",
            themes: ["nature"],
            customPrompt: "Say hello in one word.",
          },
        }),
      });

      if (!res.ok) {
        setTestResult({ text: `Error ${res.status}`, success: false });
      } else {
        const reader = res.body?.getReader();
        let received = false;
        if (reader) {
          const { done, value } = await reader.read();
          if (!done && value && value.length > 0) received = true;
          reader.cancel();
        }
        setTestResult({
          text: received ? "Connection successful!" : "No response received.",
          success: received,
        });
      }
    } catch (e) {
      setTestResult({
        text: `Test failed: ${e instanceof Error ? e.message : "Unknown error"}`,
        success: false,
      });
    }

    setIsTesting(false);
  };

  const currentKey = getApiKey(provider);
  const hasKey = !!currentKey;
  const providerConfig = PROVIDERS.find((p) => p.value === provider)!;

  return (
    <div className="px-5 pb-8 pt-6">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-br from-gray-600 to-slate-700 shadow-lg shadow-gray-500/20 mb-3">
          <span className="text-2xl">⚙️</span>
        </div>
        <h1 className="text-xl font-extrabold bg-gradient-to-r from-violet-400 via-indigo-400 to-purple-400 bg-clip-text text-transparent">
          Settings
        </h1>
        <p className="text-sm text-gray-400 mt-1">
          Configure your AI provider
        </p>
      </div>

      {/* Provider Selection */}
      <section className="mb-7">
        <p className="text-xs font-semibold uppercase tracking-widest text-violet-300/80 mb-3">
          AI Provider
        </p>
        <div className="flex flex-col gap-2.5">
          {PROVIDERS.map((p) => (
            <button
              key={p.value}
              onClick={() => handleProviderChange(p.value)}
              className={`flex items-center gap-3.5 p-4 rounded-2xl text-left transition-all duration-200 ${
                provider === p.value
                  ? "bg-gradient-to-r from-violet-500/15 to-indigo-500/15 border-2 border-violet-400/40 shadow-md shadow-violet-500/10 scale-[1.01]"
                  : "glass hover:scale-[1.01] active:scale-[0.99]"
              }`}
            >
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all ${
                  provider === p.value
                    ? "border-violet-400"
                    : "border-gray-600"
                }`}
              >
                {provider === p.value && (
                  <div className="w-2.5 h-2.5 rounded-full bg-gradient-to-br from-violet-500 to-indigo-600" />
                )}
              </div>
              <div className="flex-1">
                <p className="font-semibold text-sm text-white">
                  {p.displayName}
                </p>
                <p className="text-xs text-gray-400 mt-0.5">
                  {p.defaultModel}
                </p>
              </div>
              {provider === p.value && (
                <div className="w-2 h-2 rounded-full bg-violet-500 animate-pulse" />
              )}
            </button>
          ))}
        </div>
      </section>

      {/* API Key */}
      <section className="mb-7">
        <p className="text-xs font-semibold uppercase tracking-widest text-violet-300/80 mb-3">
          API Key
        </p>

        <div className="glass rounded-2xl p-4 space-y-3">
          <input
            type="password"
            value={keyInput}
            onChange={(e) => {
              setKeyInput(e.target.value);
              setMessage(null);
            }}
            placeholder={providerConfig.placeholder}
            className="w-full p-3.5 rounded-xl bg-white/[0.07] border border-white/[0.14] text-sm font-mono text-white focus:ring-2 focus:ring-violet-500/50 focus:border-violet-400/60 focus:outline-none placeholder:text-gray-500 transition-colors duration-200"
          />

          <div className="flex gap-2">
            <button
              onClick={handleSave}
              className="flex-1 py-3 rounded-xl bg-gradient-to-r from-violet-600 to-indigo-600 text-white text-sm font-bold hover:shadow-lg hover:shadow-violet-500/25 active:scale-[0.98] transition-all duration-200"
            >
              🔒 Save Key
            </button>
            {hasKey && (
              <button
                onClick={handleDelete}
                className="py-3 px-5 rounded-xl bg-rose-500/10 text-rose-400 text-sm font-semibold hover:bg-rose-500/20 active:scale-[0.98] transition-all duration-200"
              >
                Remove
              </button>
            )}
          </div>

          {message && (
            <p
              className={`text-xs font-medium ${
                message.success
                  ? "text-emerald-400"
                  : "text-rose-400"
              }`}
            >
              {message.success ? "✓" : "✗"} {message.text}
            </p>
          )}
        </div>

        <p className="text-xs text-gray-400 mt-3 text-center">
          🔐 Stored locally in your browser — never sent to our servers.
        </p>
      </section>

      {/* Test Connection */}
      <section className="mb-7">
        <p className="text-xs font-semibold uppercase tracking-widest text-violet-300/80 mb-3">
          Connection Test
        </p>
        <button
          onClick={handleTest}
          disabled={isTesting || !hasKey}
          className="w-full py-3.5 rounded-2xl glass text-sm font-semibold text-gray-300 disabled:opacity-30 disabled:cursor-not-allowed hover:scale-[1.01] active:scale-[0.99] transition-all duration-200"
        >
          {isTesting ? (
            <span className="flex items-center justify-center gap-2">
              <span className="w-4 h-4 border-2 border-violet-500 border-t-transparent rounded-full animate-spin" />
              Testing...
            </span>
          ) : (
            "📡 Test Connection"
          )}
        </button>
        {testResult && (
          <div
            className={`mt-3 p-3 rounded-xl text-xs font-medium text-center ${
              testResult.success
                ? "bg-emerald-500/10 text-emerald-400"
                : "bg-rose-500/10 text-rose-400"
            }`}
          >
            {testResult.success ? "✓" : "✗"} {testResult.text}
          </div>
        )}
      </section>

      {/* Config Summary */}
      <section>
        <p className="text-xs font-semibold uppercase tracking-widest text-violet-300/80 mb-3">
          Current Configuration
        </p>
        <div className="glass rounded-2xl p-5 space-y-3">
          <div className="flex justify-between items-center">
            <span className="text-sm text-gray-400">Provider</span>
            <span className="text-sm font-semibold text-white">
              {providerConfig.displayName}
            </span>
          </div>
          <div className="h-px bg-white/[0.08]" />
          <div className="flex justify-between items-center">
            <span className="text-sm text-gray-400">Model</span>
            <span className="text-sm font-semibold text-white font-mono">
              {providerConfig.defaultModel}
            </span>
          </div>
          <div className="h-px bg-white/[0.08]" />
          <div className="flex justify-between items-center">
            <span className="text-sm text-gray-400">Key</span>
            <span
              className={`text-sm font-semibold ${
                hasKey
                  ? "text-emerald-400"
                  : "text-gray-500"
              }`}
            >
              {hasKey ? "✓ Configured" : "Not set"}
            </span>
          </div>
        </div>
      </section>
    </div>
  );
}
