"use client";

import { Story } from "@/lib/types";

interface StoryCompleteProps {
  story: Story;
  onSave: () => void;
  onReset: () => void;
  isSaved: boolean;
}

export default function StoryComplete({
  story,
  onSave,
  onReset,
  isSaved,
}: StoryCompleteProps) {
  const handleShare = async () => {
    const text = `${story.title}\n\n${story.content}`;
    if (navigator.share) {
      try {
        await navigator.share({ title: story.title, text });
        return;
      } catch {
        // user cancelled — fall through to clipboard
      }
    }
    await navigator.clipboard.writeText(text);
    alert("Story copied to clipboard!");
  };

  const paragraphs = story.content.split("\n\n").filter(Boolean);

  return (
    <div className="px-5 pb-8 pt-6">
      {/* Header */}
      <div className="text-center mb-6">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-br from-violet-500 to-indigo-600 shadow-lg shadow-violet-500/30 mb-3">
          <span className="text-2xl">✨</span>
        </div>
        <h2 className="text-xl font-extrabold bg-gradient-to-r from-violet-400 to-indigo-400 bg-clip-text text-transparent">
          {story.title}
        </h2>
        <p className="text-sm text-gray-400 mt-1">
          by {story.author}
        </p>
      </div>

      {/* Story card */}
      <div className="glass rounded-3xl p-6 space-y-4 mb-8 shadow-inner shadow-violet-500/[0.03]">
        {paragraphs.map((p, i) => (
          <p
            key={i}
            className="text-[17px] leading-8 text-gray-200 select-text font-serif"
          >
            {p}
          </p>
        ))}
      </div>

      {/* Action buttons */}
      <div className="flex flex-col items-center gap-4">
        <div className="flex gap-3">
          <button
            onClick={onSave}
            className={`flex items-center gap-2 px-5 py-3 rounded-2xl text-sm font-semibold transition-all duration-200 ${
              isSaved
                ? "bg-gradient-to-r from-rose-500 to-pink-500 text-white shadow-lg shadow-rose-500/25"
                : "glass text-gray-300 hover:scale-[1.02] active:scale-[0.98]"
            }`}
          >
            {isSaved ? "❤️ Saved" : "🤍 Save"}
          </button>

          <button
            onClick={handleShare}
            className="flex items-center gap-2 px-5 py-3 rounded-2xl glass text-gray-300 text-sm font-semibold hover:scale-[1.02] active:scale-[0.98] transition-all duration-200"
          >
            📤 Share
          </button>
        </div>

        <button
          onClick={onReset}
          className="text-sm text-violet-400 font-semibold hover:underline underline-offset-2 mt-1"
        >
          Generate Another
        </button>
      </div>
    </div>
  );
}
