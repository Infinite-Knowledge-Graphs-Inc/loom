import { Button } from "@base-ui/react/button";
import { signOut } from "@/auth";
import { Nav } from "@/components/nav";

export function Sidebar({ name }: { name: string }) {
  return (
    <aside className="flex w-52 shrink-0 flex-col border-r border-neutral-200 p-4">
      <p className="mb-4 px-2 text-sm font-medium">Loom</p>
      <Nav />
      <form
        className="mt-auto flex flex-col gap-2"
        action={async () => {
          "use server";
          await signOut({ redirectTo: "/login" });
        }}
      >
        <p className="truncate px-2 text-sm text-neutral-600">{name}</p>
        <Button
          type="submit"
          className="inline-flex h-8 items-center justify-center border border-neutral-950 px-3 text-sm hover:bg-neutral-100"
        >
          Sign out
        </Button>
      </form>
    </aside>
  );
}
