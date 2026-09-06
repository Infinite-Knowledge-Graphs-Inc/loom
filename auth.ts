import NextAuth from "next-auth";
import GitHub from "next-auth/providers/github";

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [GitHub],
  trustHost: true,
  pages: { signIn: "/login" },
  // ponytail: JWT until passages need a user row
  session: { strategy: "jwt" },
});
