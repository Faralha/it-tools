<script setup lang="ts">
import { generateNumeronym } from './numeronym-generator.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const word = ref('');

const numeronym = computed(() => generateNumeronym(word.value));
</script>

<template>
  <div flex flex-col items-center gap-4>
    <c-input-text v-model:value="word" placeholder="Enter a word, e.g. 'internationalization'" size="large" clearable test-id="word-input" />

    <icon-mdi-arrow-down text-30px />

    <CodeSnippet :value="numeronym" test-id="numeronym" />
  </div>
</template>
