import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import categoryLink from "discourse/helpers/category-link";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

@block("theme:branded-custom-homepage:featured-topics", {
  description: "Card grid of topics filtered by tag",
  args: {
    title: { type: "string" },
    linkText: { type: "string" },
    linkUrl: { type: "string" },
    tag: { type: "string", required: true },
    count: { type: "number", default: 6 },
    filter: { type: "string", default: "latest" },
    emptyMessage: { type: "string" },
  },
})
export default class BlockFeaturedTopics extends Component {
  @service store;

  @bind
  async fetchTopics() {
    const tag = this.args.tag;
    const filter = `tag/${tag}/l/${this.args.filter || "latest"}`;
    const count = this.args.count || 6;

    const topicList = await this.store.findFiltered("topicList", { filter });
    if (!topicList.topics?.length) {
      return null;
    }
    return topicList.topics.slice(0, count);
  }

  <template>
    <AsyncContent @asyncData={{this.fetchTopics}}>
      <:loading>
        <div class="block-featured-topics__loading">
          <div class="spinner" />
        </div>
      </:loading>

      <:empty>
        <div class="block-featured-topics__empty">
          {{#if @emptyMessage}}
            {{i18n (themePrefix @emptyMessage)}}
          {{else}}
            {{i18n "topics.none.latest"}}
          {{/if}}
        </div>
      </:empty>

      <:content as |topics|>
        <div class="block-featured-topics__layout">
          {{#if @title}}
            <div class="block-featured-topics__header">
              <h2 class="block-featured-topics__heading">
                {{i18n (themePrefix @title)}}
              </h2>
              {{#if @linkUrl}}
                <a href={{@linkUrl}} class="block-featured-topics__link">{{i18n
                    (themePrefix @linkText)
                  }}</a>
              {{/if}}
            </div>
          {{/if}}

          <div class="block-featured-topics__grid">
            {{#each topics as |topic|}}
              <a
                href={{topic.url}}
                class="block-featured-topics__card
                  {{if topic.visited 'visited'}}"
              >
                <div class="block-featured-topics__card-body">
                  <h3 class="block-featured-topics__card-title">
                    {{topic.title}}
                  </h3>
                  {{#if topic.excerpt}}
                    <p class="block-featured-topics__card-excerpt">
                      {{topic.excerpt}}
                    </p>
                  {{/if}}
                </div>
                <div class="block-featured-topics__card-meta">
                  <div class="block-featured-topics__card-author">
                    {{avatar topic.creator imageSize="tiny"}}
                    <span>{{topic.creator.username}}</span>
                  </div>
                  {{categoryLink topic.category}}
                </div>
              </a>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
