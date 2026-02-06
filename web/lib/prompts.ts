import { StoryPreferences, LENGTHS, AGE_RANGES, STORY_STYLES, MAIN_CHARACTERS } from "./types";

export const SYSTEM_PROMPT = `You are a warm, imaginative children's storyteller. Your stories are:
- Age-appropriate and positive
- Engaging with vivid, sensory descriptions
- Have a clear beginning, middle, and end
- Include a gentle moral or lesson when appropriate
- Feature diverse characters and inclusive themes

Adapt your vocabulary, sentence complexity, and story depth to the specified age range:
- Toddler (2-3): Very simple sentences, repetitive patterns, familiar objects
- Preschool (4-5): Simple plots, basic emotions, gentle lessons
- Early Reader (6-8): More complex plots, richer vocabulary, chapter-like structure
- Middle Grade (9-12): Deeper themes, nuanced characters, sophisticated vocabulary

IMPORTANT: You must detect the language of the user's story idea. If the story idea is written in Portuguese, write the entire story in Brazilian Portuguese (pt-BR). If the story idea is written in English, write the entire story in English. If no story idea is provided, default to Brazilian Portuguese (pt-BR).

Write the story title on the first line (no formatting), then a blank line, then the story. Do not include any meta-commentary, just the story itself.`;

export function buildUserPrompt(prefs: StoryPreferences): string {
  const lengthConfig = LENGTHS.find((l) => l.value === prefs.length)!;
  const [min, max] = lengthConfig.wordRange;

  const parts: string[] = [
    `Write a ${prefs.mood} bedtime story that is ${min}-${max} words long.`,
  ];

  // Age range
  const ageConfig = AGE_RANGES.find((a) => a.value === prefs.ageRange);
  if (ageConfig) {
    parts.push(`Target age range: ${ageConfig.label} (${ageConfig.description}).`);
  }

  // Story style
  const styleConfig = STORY_STYLES.find((s) => s.value === prefs.storyStyle);
  if (styleConfig) {
    parts.push(`Story style: ${styleConfig.label}.`);
  }

  // Main character
  const charConfig = MAIN_CHARACTERS.find((c) => c.value === prefs.mainCharacter);
  if (charConfig) {
    if (prefs.characterName?.trim()) {
      parts.push(`The main character is ${charConfig.label.toLowerCase()} named ${prefs.characterName.trim()}.`);
    } else {
      parts.push(`The main character should be ${charConfig.label.toLowerCase()}.`);
    }
  }

  if (prefs.themes.length > 0) {
    parts.push(`Themes: ${prefs.themes.join(", ")}.`);
  }

  if (prefs.customPrompt?.trim()) {
    parts.push(`Story idea: ${prefs.customPrompt.trim()}`);
    parts.push("Write the story in the same language as the story idea above.");
  } else {
    parts.push("Write the story in Brazilian Portuguese (pt-BR).");
  }

  return parts.join(" ");
}
