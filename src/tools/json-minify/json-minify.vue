<script setup lang="ts">
import JSON5 from 'json5';
import type { UseValidationRule } from '@/composable/validation';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = '{\n\t"hello": [\n\t\t"world"\n\t]\n}';
const input = ref(defaultValue);
const output = computed(() => withDefaultOnError(() => JSON.stringify(JSON5.parse(input.value), null, 0), ''));

const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => v === '' || JSON5.parse(v),
    message: 'Provided JSON is not valid.',
  },
];

const snippetCode = `import JSON5 from 'json5';

const input = '{{input}}';

const minified = JSON.stringify(JSON5.parse(input), null, 0);

console.log(minified);
// => '{{output}}'`;

const snippetVars = computed(() => ({
  input: input.value.replace(/\s+/g, ' ').slice(0, 60),
  output: output.value.slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your raw JSON" placeholder="Paste your raw JSON here..." rows="10" autosize
    raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="Minified version of your JSON" language="json" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
