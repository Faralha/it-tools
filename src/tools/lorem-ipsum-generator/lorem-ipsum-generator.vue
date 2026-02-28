<script setup lang="ts">
import { generateLoremIpsum } from './lorem-ipsum-generator.service';
import { randIntFromInterval } from '@/utils/random';
import { computedRefreshable } from '@/composable/computedRefreshable';
import CodeSnippet from '@/components/CodeSnippet.vue';

const paragraphs = ref(1);
const sentences = ref([3, 8]);
const words = ref([8, 15]);
const startWithLoremIpsum = ref(true);
const asHTML = ref(false);

const [loremIpsumText, refreshLoremIpsum] = computedRefreshable(() =>
  generateLoremIpsum({
    paragraphCount: paragraphs.value,
    asHTML: asHTML.value,
    sentencePerParagraph: randIntFromInterval(sentences.value[0], sentences.value[1]),
    wordCount: randIntFromInterval(words.value[0], words.value[1]),
    startWithLoremIpsum: startWithLoremIpsum.value,
  }),
);

const snippetCode = `import { generateLoremIpsum } from './lorem-ipsum-generator.service';
import { randIntFromInterval } from '@/utils/random';

const lorem = generateLoremIpsum({
  paragraphCount: 1,
  asHTML: false,
  sentencePerParagraph: randIntFromInterval(3, 8),
  wordCount: randIntFromInterval(8, 15),
  startWithLoremIpsum: true,
});

console.log(lorem);
// {{output}}`;

const snippetVars = computed(() => ({
  output: loremIpsumText.value.slice(0, 80),
}));
</script>

<template>
  <c-card>
    <n-form-item label="Paragraphs" :show-feedback="false" label-width="200" label-placement="left">
      <n-slider v-model:value="paragraphs" :step="1" :min="1" :max="20" />
    </n-form-item>
    <n-form-item label="Sentences per paragraph" :show-feedback="false" label-width="200" label-placement="left">
      <n-slider v-model:value="sentences" range :step="1" :min="1" :max="50" />
    </n-form-item>
    <n-form-item label="Words per sentence" :show-feedback="false" label-width="200" label-placement="left">
      <n-slider v-model:value="words" range :step="1" :min="1" :max="50" />
    </n-form-item>
    <n-form-item label="Start with lorem ipsum ?" :show-feedback="false" label-width="200" label-placement="left">
      <n-switch v-model:value="startWithLoremIpsum" />
    </n-form-item>
    <n-form-item label="As html ?" :show-feedback="false" label-width="200" label-placement="left">
      <n-switch v-model:value="asHTML" />
    </n-form-item>

    <CodeSnippet :value="loremIpsumText" copy-message="Lorem ipsum copied to the clipboard" mt-5 />

    <div mt-5 flex justify-center gap-3>
      <c-button autofocus @click="refreshLoremIpsum">
        Refresh
      </c-button>
    </div>
  </c-card>

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
