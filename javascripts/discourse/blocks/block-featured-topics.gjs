import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import DMenu from "discourse/float-kit/components/d-menu";
import avatar from "discourse/helpers/avatar";
import categoryLink from "discourse/helpers/category-link";
import dIcon from "discourse/helpers/d-icon";
import { bind } from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import KeyValueStore from "discourse/lib/key-value-store";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

// localStorage, so a member's pick survives the session and the next visit.
// Nothing is written to the user's preferences or to the server.
const preferences = new KeyValueStore("branded_custom_homepage_");
const TAG_KEY = "featured_tag";

@block("theme:branded-custom-homepage:featured-topics", {
  description: "Card grid of topics filtered by a selectable tag",
  args: {
    tags: { type: "array", itemType: "string" },
    linkText: { type: "string" },
    count: { type: "number", default: 6 },
    filter: { type: "string", default: "latest" },
    emptyMessage: { type: "string" },
  },
})
export default class BlockFeaturedTopics extends Component {
  @service store;
  @service currentUser;

  @tracked selectedTag = this.#initialTag();

  get tags() {
    return this.args.tags ?? [];
  }

  // Anonymous visitors always get the first configured tag; only members
  // choose, and only when there is more than one tag to choose between.
  get canSwitch() {
    return !!this.currentUser && this.tags.length > 1;
  }

  get linkUrl() {
    return getURL(`/tag/${this.selectedTag}`);
  }

  #initialTag() {
    if (this.currentUser) {
      const saved = preferences.get(TAG_KEY);
      // A saved tag that has since been dropped from the setting falls back
      // to the first one rather than fetching a list nobody configured.
      if (saved && this.args.tags?.includes(saved)) {
        return saved;
      }
    }
    return this.args.tags?.[0];
  }

  @action
  selectTag(tag, close) {
    this.selectedTag = tag;
    preferences.set({ key: TAG_KEY, value: tag });
    close?.();
  }

  @bind
  async fetchTopics(tag) {
    const count = this.args.count || 6;
    const filter = `tag/${tag}/l/${this.args.filter || "latest"}`;

    const topicList = await this.store.findFiltered("topicList", {
      filter,
      params: { per_page: count },
    });

    return topicList.topics?.length ? topicList.topics.slice(0, count) : null;
  }

  <template>
    {{#if this.selectedTag}}
      <div class="block-featured-topics__layout">
        {{! The header sits outside AsyncContent so the picker stays reachable
            when the selected tag turns up empty. }}
        <div class="block-featured-topics__header">
          <h2 class="block-featured-topics__heading">
            {{#if this.canSwitch}}
              <DMenu
                @identifier="featured-topics-tag"
                @modalForMobile={{true}}
                @triggerClass="block-featured-topics__picker"
                @ariaLabel={{i18n
                  (themePrefix "homepage.featured_topics.change_tag")
                }}
              >
                <:trigger>
                  <span class="block-featured-topics__picker-name">
                    {{this.selectedTag}}
                  </span>
                  {{dIcon "angle-down"}}
                </:trigger>
                <:content as |menu|>
                  <DropdownMenu as |dropdown|>
                    {{#each this.tags as |tag|}}
                      <dropdown.item>
                        <DButton
                          class="btn-transparent block-featured-topics__tag-option
                            {{unless (eq tag this.selectedTag) '--unselected'}}"
                          @icon="check"
                          @translatedLabel={{tag}}
                          @action={{fn this.selectTag tag menu.close}}
                        />
                      </dropdown.item>
                    {{/each}}
                  </DropdownMenu>
                </:content>
              </DMenu>
            {{else}}
              {{this.selectedTag}}
            {{/if}}
          </h2>

          {{#if @linkText}}
            <DButton
              class="btn-flat block-featured-topics__link"
              @href={{this.linkUrl}}
              @translatedLabel={{i18n (themePrefix @linkText)}}
            />
          {{/if}}
        </div>

        <AsyncContent
          @asyncData={{this.fetchTopics}}
          @context={{this.selectedTag}}
          @retainWhileReloading={{true}}
        >
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
          </:content>
        </AsyncContent>
      </div>
    {{/if}}
  </template>
}
