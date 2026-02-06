"use client";

import { useState, useEffect } from "react";
import { Story } from "@/lib/types";
import { getSavedStories, deleteStory } from "@/lib/storage";

export default function HistoryPage() {
  const [stories, setStories] = useState<Story[]>([]);
  const [selected, setSelected] = useState<Story | null>(null);

  useEffect(() => {
    setStories(getSavedStories());
  }, []);

  const handleDelete = (id: string) => {
    deleteStory(id);
    setStories((prev) => prev.filter((s) => s.id !== id));
    if (selected?.id === id) setSelected(null);
  };

  if (selected) {
    const paragraphs = selected.content.split("\n\n").filter(Boolean);
    return (
      <div className="px-5 pb-8 pt-6">
        <button
          onClick={() => setSelected(null)}
          className="inline-flex items-center gap-1.5 text-sm font-semibold text-violet-600 dark:text-violet-400 mb-6 hover:gap-2.5 transition-all duration-200"
        >
          <span>←</span> Back to History
        </button>

        {/* Story Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-br from-violet-500 to-indigo-600 shadow-lg shadow-violet-500/30 mb-3">
            <span className="text-2xl">📖</span>
          </div>
          <h2 className="text-xl font-extrabold bg-gradient-to-r from-violet-700 via-indigo-600 to-purple-600 dark:from-violet-400 dark:via-indigo-400 dark:to-purple-400 bg-clip-text text-transparent">
            {selected.title}
          </h2>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
            by {selected.author}
          </p>
          <p className="text-xs text-gray-400 dark:text-gray-500 mt-1">
            {new Date(selected.createdAt).toLocaleDateString()} · {selected.readingTimeMinutes} min read
          </p>
        </div>

        {/* Story Content */}
        <div className="glass rounded-3xl p-6 space-y-4">
          {paragraphs.map((p, i) => (
            <p
              key={i}
              className="text-[17px] leading-8 text-gray-800 dark:text-gray-200 font-serif select-text"
            >
              {p}
            </p>
          ))}
        </div>

        {/* Delete button */}
        <div className="flex justify-center mt-6">
          <button
            onClick={() => {
              handleDelete(selected.id);
              setSelected(null);
            }}
            className="px-6 py-3 rounded-2xl bg-rose-100/80 dark:bg-rose-500/10 text-rose-600 dark:text-rose-400 text-sm font-semibold hover:bg-rose-200 dark:hover:bg-rose-500/20 active:scale-[0.98] transition-all duration-200"
          >
            🗑 Delete Story
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="px-5 pb-8 pt-6">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-br from-amber-500 to-orange-600 shadow-lg shadow-amber-500/30 mb-3">
          <span className="text-2xl">📚</span>
        </div>
        <h1 className="text-xl font-extrabold bg-gradient-to-r from-violet-700 via-indigo-600 to-purple-600 dark:from-violet-400 dark:via-indigo-400 dark:to-purple-400 bg-clip-text text-transparent">
          Saved Stories
        </h1>
        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
          Your magical collection
        </p>
      </div>

      {stories.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <div className="glass rounded-3xl p-10 inline-flex flex-col items-center">
            <div className="w-20 h-20 rounded-3xl bg-gradient-to-br from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800 flex items-center justify-center mb-5">
              <span className="text-4xl opacity-60">📖</span>
            </div>
            <p className="text-sm font-semibold text-gray-600 dark:text-gray-300 mb-1">
              No stories yet
            </p>
            <p className="text-xs text-gray-400 dark:text-gray-500 max-w-[200px]">
              Generate a story and save it to build your collection!
            </p>
          </div>
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          {stories.map((story) => (
            <div
              key={story.id}
              className="glass rounded-2xl p-4 flex items-start gap-3.5 hover:scale-[1.01] transition-all duration-200"
            >
              <button
                onClick={() => setSelected(story)}
                className="flex-1 text-left"
              >
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-sm">✨</span>
                  <p className="font-semibold text-sm text-gray-900 dark:text-white line-clamp-1">
                    {story.title}
                  </p>
                </div>
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  {story.author} · {story.readingTimeMinutes} min · {new Date(story.createdAt).toLocaleDateString()}
                </p>
                <p className="text-xs text-gray-400 dark:text-gray-500 mt-1.5 line-clamp-2 leading-relaxed">
                  {story.content.slice(0, 120)}...
                </p>
              </button>
              <button
                onClick={() => handleDelete(story.id)}
                className="text-gray-400 hover:text-rose-500 transition-all duration-200 text-sm p-1.5 rounded-lg hover:bg-rose-50 dark:hover:bg-rose-500/10"
                title="Delete"
              >
                🗑
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
