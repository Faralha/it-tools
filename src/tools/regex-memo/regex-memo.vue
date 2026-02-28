<script setup lang="ts">
import { useThemeVars } from 'naive-ui';
import Memo from './regex-memo.content.md';
import CodeSnippet from '@/components/CodeSnippet.vue';

const themeVars = useThemeVars();

const snippetCode = `// Common regex patterns and usage in JavaScript

const pattern = /{{pattern}}/g;
const text    = '{{text}}';

// Test if pattern matches
const isMatch = pattern.test(text); // => {{isMatch}}

// Find all matches
const matches = [...text.matchAll(pattern)];
// => {{matchCount}} match(es)

// Replace
const replaced = text.replace(pattern, '{{replacement}}');`;

const pattern = ref('[a-z]+');
const text = ref('hello world 123');

const snippetVars = computed(() => {
  let isMatch = false;
  let matchCount = 0;
  try {
    const re = new RegExp(pattern.value, 'g');
    isMatch = re.test(text.value);
    matchCount = [...text.value.matchAll(new RegExp(pattern.value, 'g'))].length;
  }
  catch { /* ignore invalid regex */ }
  return {
    pattern: pattern.value,
    text: text.value.slice(0, 40),
    isMatch: String(isMatch),
    matchCount: String(matchCount),
    replacement: 'X',
  };
});
</script>

<template>
  <div>
    <Memo />
  </div>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>

<style lang="less" scoped>
::v-deep(pre) {
  margin: 0;
  padding: 15px 22px;
  background-color: v-bind('themeVars.cardColor');
  border-radius: 4px;
  overflow: auto;
}

::v-deep(table) {
  border-collapse: collapse;
}

::v-deep(table),
::v-deep(td),
::v-deep(th) {
  border: 1px solid v-bind('themeVars.textColor1');
  padding: 5px;
}

::v-deep(a) {
  color: v-bind('themeVars.textColor1');
}
</style>
