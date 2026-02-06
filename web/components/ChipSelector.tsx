"use client";

interface ChipOption {
  value: string;
  label: string;
  emoji: string;
  description?: string;
}

interface ChipSelectorProps {
  label: string;
  options: ChipOption[];
  selected: string | string[];
  onChange: (value: string | string[]) => void;
  multi?: boolean;
}

export default function ChipSelector({
  label,
  options,
  selected,
  onChange,
  multi = false,
}: ChipSelectorProps) {
  const isSelected = (value: string) =>
    multi ? (selected as string[]).includes(value) : selected === value;

  const handleClick = (value: string) => {
    if (multi) {
      const arr = selected as string[];
      if (arr.includes(value)) {
        onChange(arr.filter((v) => v !== value));
      } else {
        onChange([...arr, value]);
      }
    } else {
      onChange(value);
    }
  };

  // Use a grid: 2 cols for ≤4 items, 3 cols for more
  const cols = options.length <= 4 ? "grid-cols-2" : "grid-cols-3";

  return (
    <div>
      <p className="text-xs font-semibold uppercase tracking-widest text-violet-300/80 mb-3">
        {label}
      </p>
      <div className={`grid ${cols} gap-2`}>
        {options.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => handleClick(opt.value)}
            className={`px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 text-center ${
              isSelected(opt.value)
                ? "bg-gradient-to-r from-violet-500 to-indigo-500 text-white shadow-lg shadow-violet-500/30 ring-1 ring-violet-400/30 scale-[1.02]"
                : "bg-white/[0.09] border border-white/[0.14] text-gray-200 hover:border-violet-400/40 hover:bg-violet-500/15 active:scale-[0.97]"
            }`}
          >
            <span className="mr-1">{opt.emoji}</span>
            {opt.label}
          </button>
        ))}
      </div>
    </div>
  );
}
