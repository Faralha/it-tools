<script setup lang="ts">
import convert from 'xml-js';
import JSON5 from 'json5';
import { withDefaultOnError } from '@/utils/defaults';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = '{"a":{"_attributes":{"x":"1.234","y":"It\'s"}}}';
const input = ref(defaultValue);
const output = computed(() => withDefaultOnError(() => convert.js2xml(JSON5.parse(input.value), { compact: true }), ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => v === '' || JSON5.parse(v),
    message: 'Provided JSON is not valid.',
  },
];

const snippetCode = `import convert from 'xml-js';
import JSON5 from 'json5';

const input = '{{input}}';

const xml = convert.js2xml(JSON5.parse(input), { compact: true });

console.log(xml);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.slice(0, 60),
  output: output.value.slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your JSON content" placeholder="Paste your JSON content here..." rows="10"
    autosize raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="Converted XML" language="xml" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
