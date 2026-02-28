<script setup lang="ts">
import { format } from 'prettier';
import htmlParser from 'prettier/plugins/html';
import { useStorage } from '@vueuse/core';
import Editor from './editor/editor.vue';
import CodeSnippet from '@/components/CodeSnippet.vue';

const html = useStorage('html-wysiwyg-editor--html', '<h1>Hey!</h1><p>Welcome to this html wysiwyg editor</p>');

const formattedHtml = asyncComputed(() => format(html.value, { parser: 'html', plugins: [htmlParser] }), '');

const snippetCode = `import { format } from 'prettier';
import htmlParser from 'prettier/plugins/html';

const rawHtml = \`{{input}}\`;

const formatted = await format(rawHtml, {
  parser: 'html',
  plugins: [htmlParser],
});

console.log(formatted);
// => {{output}}`;

const snippetVars = computed(() => ({
  input: html.value.replace(/\n/g, ' ').slice(0, 60),
  output: formattedHtml.value.replace(/\n/g, ' ').slice(0, 60),
}));
</script>

<template>
  <Editor v-model:html="html" />
  <CodeSnippet :value="formattedHtml" language="html" />

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
