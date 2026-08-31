import { apiInitializer } from "discourse/lib/api";
import BlockHero from "../blocks/block-hero";

export default apiInitializer((api) => {
  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockHero,
      id: "homepage-hero",
      args: {
        title: "hero.title",
        subtitle: "hero.subtitle",
        buttonLabel: "hero.button_label",
        icon: settings.hero_icon,
        image: settings.hero_image,
        buttonLink: "/signup",
      },
      conditions: { type: "route", pages: ["HOMEPAGE"] },
    },
  ]);
});
