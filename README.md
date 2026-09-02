# Branded Custom Homepage

Discourse theme component that adds Meta-style custom homepage blocks.

## Installation

1. Upload component in **Admin > Customize > Themes**.
2. Attach it to your active theme.
3. Set site setting `homepage` to `custom`.
4. Visit `/` or `/custom` while signed in.

## Featured tag

Set `featured_topics_tags` to one or more tags. The first is the default and is
what signed-out visitors see. When more than one is set, signed-in members get a
dropdown on the section heading and their pick is remembered in their browser.

Leaderboard and event cards appear only when their respective Discourse
features are enabled. When attached to Horizon, homepage topic lists use its
high-context topic cards through the standard `discovery` list context.
