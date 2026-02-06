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
      <p className="text-xs font-semibold uppercase tracking-widest text-gray-500 dark:text-gray-400 mb-3">
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
                ? "bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-md shadow-violet-500/25"
                : "bg-white/80 dark:bg-white/8 border border-gray-200 dark:border-white/10 text-gray-700 dark:text-gray-300 hover:border-violet-300 dark:hover:border-violet-500/30 hover:bg-violet-50 dark:hover:bg-violet-500/10"
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
