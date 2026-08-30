import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import CookText from "discourse/components/cook-text";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";

@block("theme:branded-custom-homepage:hero", {
  description: "Hero banner with title, subtitle, and call-to-action button",
  args: {
    title: { type: "string", required: true },
    subtitle: { type: "string" },
    buttonLabel: { type: "string" },
    buttonLink: { type: "string" },
  },
})
export default class BlockHero extends Component {
  <template>
    <div class="block-hero__layout">
      <div class="block-hero__content">
        <h1 class="block-hero__title">
          {{i18n (themePrefix @title)}}
        </h1>
        {{#if @subtitle}}
          <div class="block-hero__subtitle">
            <CookText @rawText={{i18n (themePrefix @subtitle)}} />
          </div>
        {{/if}}
        {{#if @buttonLink}}
          <DButton
            class="btn-primary block-hero__button"
            @href={{@buttonLink}}
            @translatedLabel={{i18n (themePrefix @buttonLabel)}}
          />
        {{/if}}
      </div>
    </div>
  </template>
}
