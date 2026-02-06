"use client";

import { StoryPreferences, LENGTHS, MOODS, THEMES, AGE_RANGES, STORY_STYLES, MAIN_CHARACTERS } from "@/lib/types";
import ChipSelector from "./ChipSelector";

interface GenerateFormProps {
  preferences: StoryPreferences;
  onPreferencesChange: (prefs: StoryPreferences) => void;
  onGenerate: () => void;
  disabled: boolean;
  hasApiKey: boolean;
}

export default function GenerateForm({
  preferences,
  onPreferencesChange,
  onGenerate,
  disabled,
  hasApiKey,
}: GenerateFormProps) {
  return (
    <div className="flex flex-col gap-7 px-5 pb-8">
      {/* Hero */}
      <div className="text-center pt-8 pb-2">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-3xl bg-gradient-to-br from-violet-500 to-indigo-600 shadow-lg shadow-violet-500/30 mb-4">
          <span className="text-3xl">✨</span>
        </div>
        <h1 className="text-2xl font-extrabold bg-gradient-to-r from-violet-700 via-indigo-600 to-purple-600 dark:from-violet-400 dark:via-indigo-400 dark:to-purple-400 bg-clip-text text-transparent">
          Story Time
        </h1>
        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
          Create a magical bedtime story with AI
        </p>
      </div>

      {!hasApiKey && (
        <div className="glass rounded-2xl p-4 flex items-start gap-3 border-orange-200/50 dark:border-orange-500/20">
          <div className="w-10 h-10 rounded-xl bg-orange-100 dark:bg-orange-500/10 flex items-center justify-center shrink-0">
            <span className="text-lg">🔑</span>
          </div>
          <div>
            <p className="text-sm font-semibold text-gray-800 dark:text-gray-200">
              API Key Required
            </p>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
              Go to Settings to add your API key
            </p>
          </div>
        </div>
      )}

      <ChipSelector
        label="Age Range"
        options={AGE_RANGES}
        selected={preferences.ageRange}
        onChange={(v) =>
          onPreferencesChange({ ...preferences, ageRange: v as StoryPreferences["ageRange"] })
        }
      />

      <ChipSelector
        label="Story Length"
        options={LENGTHS}
        selected={preferences.length}
        onChange={(v) =>
          onPreferencesChange({ ...preferences, length: v as StoryPreferences["length"] })
        }
      />

      <ChipSelector
        label="Mood"
        options={MOODS}
        selected={preferences.mood}
        onChange={(v) =>
          onPreferencesChange({ ...preferences, mood: v as StoryPreferences["mood"] })
        }
      />

      <ChipSelector
        label="Story Style"
        options={STORY_STYLES}
        selected={preferences.storyStyle}
        onChange={(v) =>
          onPreferencesChange({ ...preferences, storyStyle: v as StoryPreferences["storyStyle"] })
        }
      />

      <ChipSelector
        label="Main Character"
        options={MAIN_CHARACTERS}
        selected={preferences.mainCharacter}
        onChange={(v) =>
          onPreferencesChange({ ...preferences, mainCharacter: v as StoryPreferences["mainCharacter"] })
        }
      />

      {/* Character Name */}
      <div>
        <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 dark:text-gray-500 mb-3">
          Character Name
          <span className="normal-case tracking-normal font-normal ml-1.5 text-gray-300 dark:text-gray-600">
            (optional — kids love hearing their name!)
          </span>
        </p>
        <input
          type="text"
          value={preferences.characterName || ""}
          onChange={(e) =>
            onPreferencesChange({ ...preferences, characterName: e.target.value })
          }
          placeholder="Luna, Max, Sofia..."
          className="w-full p-4 rounded-2xl glass text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-violet-500/50 focus:outline-none placeholder:text-gray-400 dark:placeholder:text-gray-600"
        />
      </div>

      <ChipSelector
        label="Themes"
        options={THEMES}
        selected={preferences.themes}
        onChange={(v) =>
          onPreferencesChange({ ...preferences, themes: v as StoryPreferences["themes"] })
        }
        multi
      />

      <div>
        <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 dark:text-gray-500 mb-3">
          Story Idea
        </p>
        <textarea
          value={preferences.customPrompt || ""}
          onChange={(e) =>
            onPreferencesChange({ ...preferences, customPrompt: e.target.value })
          }
          placeholder="A brave little fox who discovers a hidden garden..."
          className="w-full p-4 rounded-2xl glass text-gray-900 dark:text-white text-sm resize-none focus:ring-2 focus:ring-violet-500/50 focus:outline-none placeholder:text-gray-400 dark:placeholder:text-gray-600 min-h-[80px]"
          rows={3}
        />
      </div>

      <button
        onClick={onGenerate}
        disabled={disabled || !hasApiKey || preferences.themes.length === 0}
        className="w-full py-4 rounded-2xl bg-gradient-to-r from-violet-600 via-purple-600 to-indigo-600 text-white font-bold text-base disabled:opacity-30 disabled:cursor-not-allowed hover:shadow-xl hover:shadow-violet-500/25 active:scale-[0.98] transition-all duration-200 glow-purple"
      >
        ✨ Generate Story
      </button>
    </div>
  );
}
