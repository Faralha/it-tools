<script setup lang="ts">
import CodeSnippet from '@/components/CodeSnippet.vue';

const snippetCode = `import { diffLines } from 'diff';

const original = \`{{original}}\`;
const modified = \`{{modified}}\`;

const changes = diffLines(original, modified);

changes.forEach((part) => {
  if (part.added)   console.log('+', part.value);
  if (part.removed) console.log('-', part.value);
});`;

const snippetVars = computed(() => ({
  original: 'Hello World\nLine two',
  modified: 'Hello Universe\nLine two\nLine three',
}));
</script>

<template>
  <c-card w-full important:flex-1 important:pa-0>
    <c-diff-editor />
  </c-card>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
