<script setup lang="ts">
import { generateNumeronym } from './numeronym-generator.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const word = ref('');

const numeronym = computed(() => generateNumeronym(word.value));

const snippetCode = `// Numeronym: replace middle letters with their count
// e.g. "internationalization" => "i18n"

function generateNumeronym(word) {
  if (word.length <= 3) return word;
  return word[0] + (word.length - 2) + word[word.length - 1];
}

const input = '{{input}}';
const output = generateNumeronym(input);
console.log(output);
// {{output}}`;

const snippetVars = computed(() => ({
  input: word.value,
  output: numeronym.value,
}));
</script>

<template>
  <div flex flex-col items-center gap-4>
    <c-input-text v-model:value="word" placeholder="Enter a word, e.g. 'internationalization'" size="large" clearable test-id="word-input" />

    <icon-mdi-arrow-down text-30px />

    <CodeSnippet :value="numeronym" test-id="numeronym" />

    <c-card title="Code snippet" w-full>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
