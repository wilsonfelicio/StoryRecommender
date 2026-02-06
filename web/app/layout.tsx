import type { Metadata, Viewport } from "next";
import "./globals.css";
import BottomNav from "@/components/BottomNav";

export const metadata: Metadata = {
  title: "Softlight Stories",
  description: "AI bedtime story generator for kids",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    title: "Softlight Stories",
    statusBarStyle: "black-translucent",
  },
  icons: {
    icon: "/icon-192.png",
    apple: "/icon-192.png",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#141024",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="h-full dark">
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Lora:ital,wght@0,400;0,600;1,400&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="h-full bg-[#141024] text-gray-100 font-sans mesh-gradient">
        <main className="max-w-lg mx-auto min-h-full pb-32 overflow-y-auto">
          {children}
        </main>
        <BottomNav />
      </body>
    </html>
  );
}
