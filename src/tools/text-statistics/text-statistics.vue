<script setup lang="ts">
import { getStringSizeInBytes } from './text-statistics.service';
import { formatBytes } from '@/utils/convert';
import CodeSnippet from '@/components/CodeSnippet.vue';

const text = ref('');

const snippetCode = `// Compute text statistics in JavaScript
const text = \`{{text}}\`;

const charCount  = text.length;                          // => {{charCount}}
const wordCount  = text === '' ? 0 : text.split(/\s+/).length; // => {{wordCount}}
const lineCount  = text === '' ? 0 : text.split(/\r\n|\r|\n/).length; // => {{lineCount}}
const byteSize   = new TextEncoder().encode(text).length; // => {{byteSize}} bytes`;

const snippetVars = computed(() => ({
  text: text.value.slice(0, 40).replace(/\n/g, ' ') || 'Hello World',
  charCount: String(text.value.length),
  wordCount: String(text.value === '' ? 0 : text.value.split(/\s+/).length),
  lineCount: String(text.value === '' ? 0 : text.value.split(/\r\n|\r|\n/).length),
  byteSize: String(getStringSizeInBytes(text.value)),
}));
</script>

<template>
  <c-card>
    <c-input-text v-model:value="text" multiline placeholder="Your text..." rows="5" />

    <div mt-5 flex>
      <n-statistic label="Character count" :value="text.length" flex-1 />
      <n-statistic label="Word count" :value="text === '' ? 0 : text.split(/\s+/).length" flex-1 />
      <n-statistic label="Line count" :value="text === '' ? 0 : text.split(/\r\n|\r|\n/).length" flex-1 />
      <n-statistic label="Byte size" :value="formatBytes(getStringSizeInBytes(text))" flex-1 />
    </div>
  </c-card>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
