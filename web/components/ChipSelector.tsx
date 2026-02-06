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

  return (
    <div>
      <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 dark:text-gray-500 mb-3">
        {label}
      </p>
      <div className="flex flex-wrap gap-2">
        {options.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => handleClick(opt.value)}
            className={`px-4 py-2.5 rounded-2xl text-sm font-medium transition-all duration-200 ${
              isSelected(opt.value)
                ? "bg-gradient-to-r from-violet-600 to-indigo-600 text-white shadow-lg shadow-violet-500/25 scale-[1.03]"
                : "glass text-gray-600 dark:text-gray-300 hover:scale-[1.02] active:scale-[0.98]"
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
