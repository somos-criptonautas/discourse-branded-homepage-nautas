import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/avatar";
import number from "discourse/helpers/number";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";
import { or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

@block("theme:branded-custom-homepage:leaderboard", {
  description: "Gamification leaderboard showing top users",
  args: {
    title: { type: "string" },
    count: { type: "number", default: 8 },
    period: { type: "string", default: "weekly" },
    buttonLabel: { type: "string", required: true },
  },
})
export default class BlockLeaderboard extends Component {
  @service siteSettings;

  @bind
  async fetchLeaderboard() {
    const count = this.args.count || 8;
    let data;

    try {
      data = await ajax("/leaderboard", {
        data: { period: this.args.period, user_limit: count },
      });
    } catch {
      return null;
    }

    const users = (data.users || []).map((user, index) => ({
      ...user,
      isCurrentUser: user.id === data.personal?.user?.id,
      isTopRanked: index === 0,
    }));

    return {
      leaderboard: data.leaderboard,
      users,
      personal: data.personal,
      currentUserNotInTop: data.personal?.position > count,
    };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchLeaderboard}}>
      <:loading>
        <div class="block-leaderboard__loading"><div class="spinner" /></div>
      </:loading>

      <:content as |data|>
        <div class="block-leaderboard__layout">
          {{#if @title}}
            <div class="block-leaderboard__header">
              <h2 class="block-leaderboard__title">
                {{i18n (themePrefix @title)}}
              </h2>
              <DButton
                class="btn-flat block-leaderboard__link"
                @href="/leaderboard/{{data.leaderboard.id}}?period={{@period}}"
                @translatedLabel={{i18n (themePrefix @buttonLabel)}}
              />
            </div>
          {{/if}}

          <div class="block-leaderboard__list">
            {{#if data.currentUserNotInTop}}
              <div class="block-leaderboard__row --self">
                <span class="block-leaderboard__rank">
                  {{data.personal.position}}
                </span>
                <span class="block-leaderboard__name">
                  {{i18n "gamification.you"}}
                </span>
                <span class="block-leaderboard__score">
                  {{number data.personal.user.total_score}}
                </span>
              </div>
            {{/if}}

            {{#each data.users as |rank|}}
              <div
                class="block-leaderboard__row
                  {{if rank.isCurrentUser '--highlight'}}"
              >
                <div
                  class="block-leaderboard__user"
                  data-user-card={{rank.username}}
                >
                  {{avatar rank imageSize="small"}}
                  <span class="block-leaderboard__name">
                    {{#if this.siteSettings.prioritize_username_in_ux}}
                      {{rank.username}}
                    {{else}}
                      {{or rank.name rank.username}}
                    {{/if}}
                  </span>
                </div>
                <span class="block-leaderboard__score">
                  {{number rank.total_score}}
                </span>
              </div>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
