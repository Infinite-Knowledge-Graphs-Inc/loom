import { redirect } from "next/navigation";
import { auth } from "@/auth";
import { Sidebar } from "@/components/sidebar";

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await auth();
  if (!session?.user) redirect("/login");

  return (
    <div className="flex min-h-dvh">
      <Sidebar name={session.user.name ?? session.user.email ?? "Signed in"} />
      <main className="flex-1 p-6">{children}</main>
    </div>
  );
}
