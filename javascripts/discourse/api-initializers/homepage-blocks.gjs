import BlockGroup from "discourse/blocks/builtin/block-group";
import { apiInitializer } from "discourse/lib/api";
import getURL from "discourse/lib/get-url";
import BlockCta from "../blocks/block-cta";
import BlockFeaturedList from "../blocks/block-featured-list";
import BlockFeaturedTopics from "../blocks/block-featured-topics";
import BlockLeaderboard from "../blocks/block-leaderboard";
import BlockUpcomingEvents from "../blocks/block-upcoming-events";

// List settings arrive as a pipe-separated string.
const featuredTags = (settings.featured_topics_tags || "")
  .split("|")
  .filter(Boolean);

export default apiInitializer((api) => {
  api.renderBlocks("homepage-blocks", [
    {
      block: BlockFeaturedTopics,
      id: "featured-topics",
      args: {
        linkText: "homepage.featured_topics.link_text",
        emptyMessage: "homepage.featured_topics.empty",
        tags: featuredTags,
        count: settings.featured_topics_count,
      },
      conditions: [
        { type: "setting", name: "tagging_enabled", enabled: true },
        {
          type: "setting",
          source: settings,
          name: "featured_topics_tags",
          enabled: true,
        },
      ],
    },
    {
      block: BlockFeaturedList,
      id: "featured-list",
      args: {
        title: "homepage.featured_list.title",
        linkText: "homepage.featured_list.link_text",
        linkUrl: getURL("/latest"),
        count: settings.featured_list_count,
        filter: settings.featured_list_filter,
        emptyMessage: "homepage.featured_list.empty",
        listContext: "discovery",
      },
    },
    {
      block: BlockGroup,
      id: "homepage-right",
      children: [
        {
          block: BlockUpcomingEvents,
          id: "homepage-events",
          args: {
            title: "homepage.events.title",
            count: settings.events_count,
            buttonLabel: "homepage.events.button_label",
            linkLabel: "homepage.events.link_label",
            linkUrl: getURL("/upcoming-events"),
          },
          conditions: {
            type: "setting",
            name: "calendar_enabled",
            enabled: true,
          },
        },
        {
          block: BlockFeaturedList,
          id: "homepage-hot-topics",
          args: {
            title: "homepage.hot_topics.title",
            linkText: "homepage.hot_topics.link_text",
            linkUrl: getURL("/hot"),
            count: settings.hot_topics_count,
            filter: "hot",
            emptyMessage: "homepage.hot_topics.empty",
            listContext: "discovery",
          },
        },
        {
          block: BlockLeaderboard,
          id: "homepage-leaderboard",
          args: {
            title: "homepage.leaderboard.title",
            count: settings.leaderboard_count,
            period: "weekly",
            buttonLabel: "homepage.leaderboard.button_label",
          },
          conditions: {
            type: "setting",
            name: "discourse_gamification_enabled",
            enabled: true,
          },
        },
      ],
    },
    {
      block: BlockCta,
      id: "homepage-cta",
      args: {
        title: "homepage.cta.title",
        description: "homepage.cta.description",
        buttonLabel: "homepage.cta.button_label",
        buttonLink: getURL(settings.cta_link),
        icon: settings.cta_icon,
      },
      conditions: { type: "user", loggedIn: false },
    },
  ]);
});
