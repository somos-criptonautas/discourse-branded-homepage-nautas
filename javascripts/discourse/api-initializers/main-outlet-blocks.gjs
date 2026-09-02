import BlockHead from "discourse/blocks/builtin/block-head";
import { apiInitializer } from "discourse/lib/api";
import getURL from "discourse/lib/get-url";
import BlockHero from "../blocks/block-hero";

// Shared hero args; the signup button is added only for signed-out visitors.
const heroArgs = {
  title: "hero.title",
  subtitle: "hero.subtitle",
  icon: settings.hero_icon,
  // An unset upload setting is null, and the block args are typed as
  // strings. Empty string is falsy in the template, so no image renders.
  image: settings.hero_image || "",
};

export default apiInitializer((api) => {
  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockHead,
      id: "homepage-hero",
      conditions: { type: "route", pages: ["HOMEPAGE"] },
      children: [
        {
          block: BlockHero,
          id: "homepage-hero-anon",
          args: {
            ...heroArgs,
            buttonLabel: "hero.button_label",
            buttonLink: getURL("/signup"),
          },
          conditions: { type: "user", loggedIn: false },
        },
        // Signed in: same hero, no "Get started" pitch.
        { block: BlockHero, id: "homepage-hero-user", args: heroArgs },
      ],
    },
  ]);
});
