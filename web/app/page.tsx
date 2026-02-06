"use client";

import { useState, useEffect, useCallback } from "react";
import { StoryPreferences, Story } from "@/lib/types";
import {
  getPreferences,
  savePreferences,
  getSelectedProvider,
  getApiKey,
  getSavedStories,
  saveStory,
  deleteStory,
  hasApiKey,
  checkBuiltInKey,
} from "@/lib/storage";
import GenerateForm from "@/components/GenerateForm";
import StreamingStory from "@/components/StreamingStory";
import StoryComplete from "@/components/StoryComplete";

type AppState =
  | { status: "idle" }
  | { status: "generating"; text: string }
  | { status: "done"; story: Story }
  | { status: "error"; message: string };

export default function GeneratePage() {
  const [state, setState] = useState<AppState>({ status: "idle" });
  const [preferences, setPreferences] = useState<StoryPreferences>({
    length: "medium",
    mood: "adventure",
    themes: ["animals"],
    ageRange: "preschool",
    storyStyle: "classicFairytale",
    mainCharacter: "child",
  });
  const [keyAvailable, setKeyAvailable] = useState(false);
  const [hasBuiltIn, setHasBuiltIn] = useState(false);
  const [isSaved, setIsSaved] = useState(false);

  useEffect(() => {
    setPreferences(getPreferences());
    setKeyAvailable(hasApiKey());
    // Check if server has a built-in fallback key
    checkBuiltInKey().then(setHasBuiltIn);
  }, []);

  // Re-check key when page becomes visible (user may come back from settings)
  useEffect(() => {
    const handleVisibility = () => {
      if (!document.hidden) setKeyAvailable(hasApiKey());
    };
    const handleFocus = () => setKeyAvailable(hasApiKey());
    document.addEventListener("visibilitychange", handleVisibility);
    window.addEventListener("focus", handleFocus);
    return () => {
      document.removeEventListener("visibilitychange", handleVisibility);
      window.removeEventListener("focus", handleFocus);
    };
  }, []);

  // User has a key OR the server has a built-in Anthropic key and Anthropic is selected
  const canGenerate =
    keyAvailable ||
    (hasBuiltIn && getSelectedProvider() === "anthropic");

  const handlePreferencesChange = (prefs: StoryPreferences) => {
    setPreferences(prefs);
    savePreferences(prefs);
  };

  const handleGenerate = useCallback(async () => {
    const provider = getSelectedProvider();
    const apiKey = getApiKey(provider);

    // If no user key but we have a built-in Anthropic key, send empty string
    // and let the server use its fallback
    if (!apiKey && !(hasBuiltIn && provider === "anthropic")) return;

    setState({ status: "generating", text: "" });
    setIsSaved(false);

    try {
      const res = await fetch("/api/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ provider, apiKey, preferences }),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({ error: `Error ${res.status}` }));
        setState({ status: "error", message: err.error || `Error ${res.status}` });
        return;
      }

      const reader = res.body?.getReader();
      if (!reader) {
        setState({ status: "error", message: "No response stream" });
        return;
      }

      const decoder = new TextDecoder();
      let fullText = "";
      let buffer = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() || "";

        for (const line of lines) {
          if (line.startsWith("data: ")) {
            try {
              const { text } = JSON.parse(line.slice(6));
              if (text) {
                fullText += text;
                setState({ status: "generating", text: fullText });
              }
            } catch {
              // skip malformed lines
            }
          }
        }
      }

      // Parse title from first line
      const lines = fullText.trim().split("\n");
      let title = "A Bedtime Story";
      let content = fullText;

      if (lines[0] && lines[0].length < 80) {
        title = lines[0].replace(/^#+\s*/, "").replace(/^\*+|\*+$/g, "").trim();
        content = lines.slice(1).join("\n").trim();
      }

      const wordCount = content.split(/\s+/).length;
      const readingTime = Math.max(1, Math.round(wordCount / 200));

      const story: Story = {
        id: `gen-${Date.now().toString(36)}`,
        title,
        author: `AI Storyteller (${provider})`,
        content,
        length: preferences.length,
        mood: preferences.mood,
        themes: preferences.themes,
        readingTimeMinutes: readingTime,
        createdAt: new Date().toISOString(),
      };

      setState({ status: "done", story });
    } catch (e) {
      setState({
        status: "error",
        message: e instanceof Error ? e.message : "Something went wrong",
      });
    }
  }, [preferences, hasBuiltIn]);

  const handleSave = () => {
    if (state.status !== "done") return;
    const stories = getSavedStories();
    const exists = stories.some((s) => s.id === state.story.id);
    if (exists) {
      deleteStory(state.story.id);
      setIsSaved(false);
    } else {
      saveStory(state.story);
      setIsSaved(true);
    }
  };

  const handleReset = () => {
    setState({ status: "idle" });
    setKeyAvailable(hasApiKey());
  };

  switch (state.status) {
    case "idle":
      return (
        <GenerateForm
          preferences={preferences}
          onPreferencesChange={handlePreferencesChange}
          onGenerate={handleGenerate}
          disabled={false}
          hasApiKey={canGenerate}
        />
      );

    case "generating":
      return <StreamingStory text={state.text} />;

    case "done":
      return (
        <StoryComplete
          story={state.story}
          onSave={handleSave}
          onReset={handleReset}
          isSaved={isSaved}
        />
      );

    case "error":
      return (
        <div className="flex flex-col items-center justify-center min-h-[60vh] px-8 text-center">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-3xl bg-gradient-to-br from-rose-500 to-orange-500 shadow-lg shadow-rose-500/30 mb-4">
            <span className="text-3xl">😕</span>
          </div>
          <h2 className="text-lg font-bold text-white mb-2">
            Oops!
          </h2>
          <p className="text-sm text-gray-400 mb-6 max-w-xs">
            {state.message}
          </p>
          <button
            onClick={handleReset}
            className="px-8 py-3.5 rounded-2xl bg-gradient-to-r from-violet-600 via-purple-600 to-indigo-600 text-white font-bold text-sm hover:shadow-xl hover:shadow-violet-500/25 active:scale-[0.98] transition-all duration-200 glow-purple"
          >
            ✨ Try Again
          </button>
        </div>
      );
  }
}
