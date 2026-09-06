import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Loom",
  description: "Read sources and connect passages into concepts.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <div className="root">{children}</div>
      </body>
    </html>
  );
}
