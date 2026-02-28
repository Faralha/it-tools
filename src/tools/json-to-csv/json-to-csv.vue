<script setup lang="ts">
import JSON5 from 'json5';
import { convertArrayToCsv } from './json-to-csv.service';
import type { UseValidationRule } from '@/composable/validation';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = '[{"name":"Alice","age":30},{"name":"Bob","age":25}]';
const input = ref(defaultValue);
const output = computed(() => withDefaultOnError(() => {
  if (input.value === '') {
    return '';
  }
  return convertArrayToCsv({ array: JSON5.parse(input.value) });
}, ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => v === '' || JSON5.parse(v),
    message: 'Provided JSON is not valid.',
  },
];

const snippetCode = `import JSON5 from 'json5';

const data = '{{input}}';
const rows = JSON5.parse(data);

const headers = Object.keys(rows[0]);
const csv = [
  headers.join(','),
  ...rows.map(r => headers.map(h => r[h]).join(',')),
].join('\\n');

console.log(csv);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.slice(0, 60),
  output: output.value.replace(/\n/g, '\\n').slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your raw JSON" placeholder="Paste your raw JSON here..." rows="10" autosize
    raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="CSV version of your JSON" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
