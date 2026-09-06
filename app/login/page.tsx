import { redirect } from "next/navigation";
import { Button } from "@base-ui/react/button";
import { auth, signIn } from "@/auth";

export default async function LoginPage() {
  const session = await auth();
  if (session) redirect("/read");

  return (
    <main className="flex min-h-dvh items-center justify-center">
      <form
        action={async () => {
          "use server";
          await signIn("github", { redirectTo: "/read" });
        }}
      >
        <Button
          type="submit"
          className="inline-flex h-8 items-center border border-neutral-950 px-3 text-sm hover:bg-neutral-100"
        >
          Sign in with GitHub
        </Button>
      </form>
    </main>
  );
}
