import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import BasicTopicList from "discourse/components/basic-topic-list";
import DButton from "discourse/components/d-button";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

@block("theme:branded-custom-homepage:featured-list", {
  description: "A filterable list of topics with heading and link",
  args: {
    title: { type: "string" },
    linkText: { type: "string" },
    linkUrl: { type: "string" },
    count: { type: "number", default: 10 },
    filter: { type: "string", default: "latest" },
    emptyMessage: { type: "string" },
    listContext: { type: "string", default: "discovery" },
  },
})
export default class BlockFeaturedList extends Component {
  @service store;

  @bind
  async fetchTopics() {
    const filter = this.args.filter || "latest";
    const count = this.args.count || 10;

    const topicList = await this.store.findFiltered("topicList", { filter });
    if (!topicList.topics?.length) {
      return null;
    }
    return topicList.topics.slice(0, count);
  }

  <template>
    <AsyncContent @asyncData={{this.fetchTopics}}>
      <:loading>
        <div class="block-featured-list__loading"><div class="spinner" /></div>
      </:loading>

      <:empty>
        <div class="block-featured-list__empty">
          {{#if @emptyMessage}}
            {{i18n (themePrefix @emptyMessage)}}
          {{else}}
            {{i18n "topics.none.latest"}}
          {{/if}}
        </div>
      </:empty>

      <:content as |topics|>
        <div class="block-featured-list__layout">
          {{#if @title}}
            <div class="block-featured-list__header">
              <h2 class="block-featured-list__title">
                {{i18n (themePrefix @title)}}
              </h2>
              {{#if @linkUrl}}
                <DButton
                  class="btn-flat block-featured-list__link"
                  @href={{@linkUrl}}
                  @translatedLabel={{i18n (themePrefix @linkText)}}
                />
              {{/if}}
            </div>
          {{/if}}
          <div class="block-featured-list__list">
            <BasicTopicList
              @topics={{topics}}
              @showPosters={{true}}
              @listContext={{@listContext}}
            />
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
