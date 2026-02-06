export type LLMProvider = "anthropic" | "openai" | "gemini";

export type StoryLength = "short" | "medium" | "long";
export type StoryMood =
  | "funny"
  | "adventure"
  | "calming"
  | "educational"
  | "suspenseful"
  | "heartwarming"
  | "silly";
export type StoryTheme =
  | "nature"
  | "animals"
  | "music"
  | "space"
  | "friendship"
  | "fantasy"
  | "royalty"
  | "dinosaurs"
  | "ocean"
  | "superheroes"
  | "cooking";
export type AgeRange = "toddler" | "preschool" | "earlyReader" | "middleGrade";
export type StoryStyle = "classicFairytale" | "rhyming" | "interactive" | "fable";
export type MainCharacter = "child" | "animal" | "robot" | "magicalBeing";

export interface StoryPreferences {
  length: StoryLength;
  mood: StoryMood;
  themes: StoryTheme[];
  ageRange: AgeRange;
  storyStyle: StoryStyle;
  mainCharacter: MainCharacter;
  characterName?: string;
  customPrompt?: string;
}

export interface Story {
  id: string;
  title: string;
  author: string;
  content: string;
  length: StoryLength;
  mood: StoryMood;
  themes: StoryTheme[];
  readingTimeMinutes: number;
  createdAt: string;
}

export const LENGTHS: { value: StoryLength; label: string; emoji: string; description: string; wordRange: [number, number] }[] = [
  { value: "short", label: "Short", emoji: "🌙", description: "2-3 min read", wordRange: [300, 600] },
  { value: "medium", label: "Medium", emoji: "🌟", description: "5-7 min read", wordRange: [800, 1400] },
  { value: "long", label: "Long", emoji: "📖", description: "10-15 min read", wordRange: [1800, 3000] },
];

export const MOODS: { value: StoryMood; label: string; emoji: string }[] = [
  { value: "funny", label: "Funny", emoji: "😄" },
  { value: "adventure", label: "Adventure", emoji: "🗺️" },
  { value: "calming", label: "Calming", emoji: "😌" },
  { value: "educational", label: "Educational", emoji: "🧠" },
  { value: "suspenseful", label: "Suspenseful", emoji: "🫣" },
  { value: "heartwarming", label: "Heartwarming", emoji: "💖" },
  { value: "silly", label: "Silly", emoji: "🤪" },
];

export const THEMES: { value: StoryTheme; label: string; emoji: string }[] = [
  { value: "nature", label: "Nature", emoji: "🌿" },
  { value: "animals", label: "Animals", emoji: "🐾" },
  { value: "music", label: "Music", emoji: "🎵" },
  { value: "space", label: "Space", emoji: "🚀" },
  { value: "friendship", label: "Friendship", emoji: "🤝" },
  { value: "fantasy", label: "Fantasy", emoji: "🧙" },
  { value: "royalty", label: "Royalty", emoji: "🏰" },
  { value: "dinosaurs", label: "Dinosaurs", emoji: "🦕" },
  { value: "ocean", label: "Ocean", emoji: "🌊" },
  { value: "superheroes", label: "Superheroes", emoji: "🦸" },
  { value: "cooking", label: "Cooking", emoji: "🍪" },
];

export const AGE_RANGES: { value: AgeRange; label: string; emoji: string; description: string }[] = [
  { value: "toddler", label: "Toddler", emoji: "👶", description: "Ages 2-3" },
  { value: "preschool", label: "Preschool", emoji: "🧒", description: "Ages 4-5" },
  { value: "earlyReader", label: "Early Reader", emoji: "📚", description: "Ages 6-8" },
  { value: "middleGrade", label: "Middle Grade", emoji: "🧑", description: "Ages 9-12" },
];

export const STORY_STYLES: { value: StoryStyle; label: string; emoji: string; description: string }[] = [
  { value: "classicFairytale", label: "Classic Fairytale", emoji: "📖", description: "Once upon a time..." },
  { value: "rhyming", label: "Rhyming", emoji: "🔁", description: "Rhythmic & repetitive" },
  { value: "interactive", label: "Interactive", emoji: "🗣️", description: "Choose your path" },
  { value: "fable", label: "Fable", emoji: "📝", description: "With a moral lesson" },
];

export const MAIN_CHARACTERS: { value: MainCharacter; label: string; emoji: string }[] = [
  { value: "child", label: "A Child", emoji: "🧒" },
  { value: "animal", label: "An Animal", emoji: "🐻" },
  { value: "robot", label: "A Robot", emoji: "🤖" },
  { value: "magicalBeing", label: "Magical Being", emoji: "👸" },
];

export const PROVIDERS: {
  value: LLMProvider;
  displayName: string;
  defaultModel: string;
  placeholder: string;
}[] = [
  { value: "anthropic", displayName: "Anthropic (Claude)", defaultModel: "claude-sonnet-4-20250514", placeholder: "sk-ant-api03-..." },
  { value: "openai", displayName: "OpenAI (GPT)", defaultModel: "gpt-4o", placeholder: "sk-..." },
  { value: "gemini", displayName: "Google (Gemini)", defaultModel: "gemini-2.0-flash", placeholder: "AIza..." },
];
