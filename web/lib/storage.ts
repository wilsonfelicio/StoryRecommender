import { LLMProvider, Story, StoryPreferences } from "./types";

const KEYS = {
  provider: "storytime_provider",
  apiKeyPrefix: "storytime_apikey_",
  stories: "storytime_stories",
  preferences: "storytime_preferences",
};

// Provider
export function getSelectedProvider(): LLMProvider {
  if (typeof window === "undefined") return "anthropic";
  return (localStorage.getItem(KEYS.provider) as LLMProvider) || "anthropic";
}

export function setSelectedProvider(provider: LLMProvider) {
  localStorage.setItem(KEYS.provider, provider);
}

// API Keys
export function getApiKey(provider: LLMProvider): string {
  if (typeof window === "undefined") return "";
  return localStorage.getItem(KEYS.apiKeyPrefix + provider) || "";
}

export function saveApiKey(provider: LLMProvider, key: string) {
  if (key) {
    localStorage.setItem(KEYS.apiKeyPrefix + provider, key);
  } else {
    localStorage.removeItem(KEYS.apiKeyPrefix + provider);
  }
}

export function deleteApiKey(provider: LLMProvider) {
  localStorage.removeItem(KEYS.apiKeyPrefix + provider);
}

export function hasApiKey(): boolean {
  if (typeof window === "undefined") return false;
  const provider = getSelectedProvider();
  return !!getApiKey(provider);
}

// Check if the server has a built-in Anthropic key as fallback
export async function checkBuiltInKey(): Promise<boolean> {
  try {
    const res = await fetch("/api/config");
    if (!res.ok) return false;
    const data = await res.json();
    return data.hasBuiltInKey === true;
  } catch {
    return false;
  }
}

// Stories
export function getSavedStories(): Story[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(KEYS.stories);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

export function saveStory(story: Story) {
  const stories = getSavedStories();
  stories.unshift(story);
  // Keep max 50 stories
  const trimmed = stories.slice(0, 50);
  localStorage.setItem(KEYS.stories, JSON.stringify(trimmed));
}

export function deleteStory(id: string) {
  const stories = getSavedStories().filter((s) => s.id !== id);
  localStorage.setItem(KEYS.stories, JSON.stringify(stories));
}

// Preferences
export function getPreferences(): StoryPreferences {
  const defaults: StoryPreferences = {
    length: "short",
    mood: "calming",
    themes: ["animals"],
    ageRange: "toddler",
    storyStyle: "classicFairytale",
    mainCharacter: "child",
  };
  if (typeof window === "undefined") {
    return defaults;
  }
  try {
    const raw = localStorage.getItem(KEYS.preferences);
    if (raw) {
      const parsed = JSON.parse(raw);
      // Merge with defaults to handle missing new fields from old saved prefs
      return { ...defaults, ...parsed };
    }
  } catch {
    // fall through
  }
  return defaults;
}

export function savePreferences(prefs: StoryPreferences) {
  localStorage.setItem(KEYS.preferences, JSON.stringify(prefs));
}
