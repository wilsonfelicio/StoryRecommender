"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const tabs = [
  { href: "/", label: "Generate", icon: "✨", activeIcon: "✨" },
  { href: "/history", label: "History", icon: "📖", activeIcon: "📖" },
  { href: "/settings", label: "Settings", icon: "⚙️", activeIcon: "⚙️" },
];

export default function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50">
      <div className="max-w-lg mx-auto px-4 pb-[env(safe-area-inset-bottom)]">
        <div className="bg-white/90 dark:bg-gray-900/90 backdrop-blur-xl border border-gray-200/60 dark:border-white/10 rounded-2xl mb-2 px-2 py-1 flex shadow-lg shadow-black/8 dark:shadow-black/30">
          {tabs.map((tab) => {
            const active =
              tab.href === "/" ? pathname === "/" : pathname.startsWith(tab.href);
            return (
              <Link
                key={tab.href}
                href={tab.href}
                className={`flex-1 flex flex-col items-center py-2.5 rounded-xl text-xs font-medium transition-all duration-200 ${
                  active
                    ? "bg-violet-100 dark:bg-violet-500/15 text-violet-700 dark:text-violet-300 scale-105"
                    : "text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-400"
                }`}
              >
                <span className="text-lg mb-0.5">
                  {active ? tab.activeIcon : tab.icon}
                </span>
                <span className="tracking-wide">{tab.label}</span>
              </Link>
            );
          })}
        </div>
      </div>
    </nav>
  );
}
