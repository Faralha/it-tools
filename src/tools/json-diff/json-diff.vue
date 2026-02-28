<script setup lang="ts">
import JSON5 from 'json5';

import DiffsViewer from './diff-viewer/diff-viewer.vue';
import { withDefaultOnError } from '@/utils/defaults';
import { isNotThrowing } from '@/utils/boolean';
import CodeSnippet from '@/components/CodeSnippet.vue';

const rawLeftJson = ref('');
const rawRightJson = ref('');

const leftJson = computed(() => withDefaultOnError(() => JSON5.parse(rawLeftJson.value), undefined));
const rightJson = computed(() => withDefaultOnError(() => JSON5.parse(rawRightJson.value), undefined));

const jsonValidationRules = [
  {
    validator: (value: string) => value === '' || isNotThrowing(() => JSON5.parse(value)),
    message: 'Invalid JSON format',
  },
];

const snippetCode = `import JSON5 from 'json5';

// Parse and compare two JSON objects
const left = JSON5.parse('{{left}}');
const right = JSON5.parse('{{right}}');

// Find differences between two objects
function getJsonDiff(a, b, path = '') {
  const diffs = [];
  const keys = new Set([...Object.keys(a || {}), ...Object.keys(b || {})]);
  for (const key of keys) {
    const p = path ? path + '.' + key : key;
    if (JSON.stringify(a?.[key]) !== JSON.stringify(b?.[key])) {
      diffs.push({ path: p, left: a?.[key], right: b?.[key] });
    }
  }
  return diffs;
}

const diffs = getJsonDiff(left, right);
console.log('Differences found:', diffs.length); // => {{diffCount}}`;

const snippetVars = computed(() => {
  const l = rawLeftJson.value.replace(/\n/g, ' ').slice(0, 30) || '{"a":1}';
  const r = rawRightJson.value.replace(/\n/g, ' ').slice(0, 30) || '{"a":2}';
  let diffCount = 0;
  try {
    if (leftJson.value && rightJson.value) {
      const allKeys = new Set([...Object.keys(leftJson.value as object), ...Object.keys(rightJson.value as object)]);
      for (const key of allKeys) {
        if (JSON.stringify((leftJson.value as any)[key]) !== JSON.stringify((rightJson.value as any)[key])) {
          diffCount++;
        }
      }
    }
  }
  catch (_) {}
  return { left: l, right: r, diffCount: String(diffCount) };
});
</script>

<template>
  <c-input-text
    v-model:value="rawLeftJson"
    :validation-rules="jsonValidationRules"
    label="Your first JSON"
    placeholder="Paste your first JSON here..."
    rows="20"
    multiline
    test-id="leftJson"
    raw-text
    monospace
  />

  <c-input-text
    v-model:value="rawRightJson"
    :validation-rules="jsonValidationRules"
    label="Your JSON to compare"
    placeholder="Paste your JSON to compare here..."
    rows="20"
    multiline
    test-id="rightJson"
    raw-text
    monospace
  />

  <DiffsViewer :left-json="leftJson" :right-json="rightJson" />

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
