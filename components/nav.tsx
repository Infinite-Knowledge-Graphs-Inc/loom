"use client";

import NextLink from "next/link";
import { usePathname } from "next/navigation";
import { NavigationMenu } from "@base-ui/react/navigation-menu";

function Link(props: NavigationMenu.Link.Props) {
  return (
    <NavigationMenu.Link
      render={<NextLink href={props.href ?? "/"} />}
      {...props}
    />
  );
}

export function Nav() {
  const pathname = usePathname();

  return (
    <NavigationMenu.Root orientation="vertical">
      <NavigationMenu.List className="flex flex-col gap-1">
        <NavigationMenu.Item>
          <Link
            href="/read"
            active={pathname === "/read"}
            className="block px-2 py-1 text-sm data-active:bg-neutral-200"
          >
            Read
          </Link>
        </NavigationMenu.Item>
        <NavigationMenu.Item>
          <Link
            href="/connect"
            active={pathname === "/connect"}
            className="block px-2 py-1 text-sm data-active:bg-neutral-200"
          >
            Connect
          </Link>
        </NavigationMenu.Item>
      </NavigationMenu.List>
    </NavigationMenu.Root>
  );
}
