"use client";

import { useEffect, useRef } from "react";

interface StreamingStoryProps {
  text: string;
}

export default function StreamingStory({ text }: StreamingStoryProps) {
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [text]);

  const paragraphs = text.split("\n\n").filter(Boolean);

  return (
    <div className="px-5 pb-8 pt-6">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-gradient-to-br from-violet-500 to-indigo-600 shadow-lg shadow-violet-500/30 mb-3">
          <span className="text-2xl">✨</span>
        </div>
        <h2 className="text-lg font-bold text-gray-900 dark:text-white">
          Writing your story...
        </h2>
        <div className="shimmer h-0.5 w-32 mx-auto mt-3 rounded-full" />
      </div>

      {/* Story text */}
      <div className="glass rounded-3xl p-6 space-y-4">
        {paragraphs.map((p, i) => (
          <p
            key={i}
            className="text-[17px] leading-8 text-gray-800 dark:text-gray-200 font-serif"
          >
            {p}
            {i === paragraphs.length - 1 && (
              <span className="inline-block w-0.5 h-5 bg-violet-500 ml-0.5 animate-cursor rounded-full" />
            )}
          </p>
        ))}
      </div>

      {/* Loading dots */}
      <div className="flex justify-center gap-2 mt-6">
        {[0, 1, 2].map((i) => (
          <span
            key={i}
            className="w-2 h-2 bg-violet-400 dark:bg-violet-500 rounded-full animate-soft-bounce"
            style={{ animationDelay: `${i * 0.2}s` }}
          />
        ))}
      </div>

      <div ref={bottomRef} />
    </div>
  );
}
