<script setup lang="ts">
import { stringify as stringifyToml } from 'iarna-toml-esm';
import JSON5 from 'json5';
import { withDefaultOnError } from '../../utils/defaults';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = '{"name": "Alice", "age": 30}';
const input = ref(defaultValue);
const convertJsonToToml = (value: string) => [stringifyToml(JSON5.parse(value))].flat().join('\n').trim();
const output = computed(() => input.value.trim() === '' ? '' : withDefaultOnError(() => convertJsonToToml(input.value), ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => v === '' || JSON5.parse(v),
    message: 'Provided JSON is not valid.',
  },
];

const snippetCode = `import JSON5 from 'json5';
import { stringify as toToml } from 'iarna-toml-esm';

const input = '{{input}}';

const toml = toToml(JSON5.parse(input));

console.log(toml);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.replace(/\n/g, ' ').slice(0, 60),
  output: output.value.slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input"
    label="Your JSON"
    placeholder="Paste your JSON here..."
    rows="10"
    autosize
    raw-text
    multiline
    :validation-rules="rules"
    monospace
  />

  <CodeSnippet :value="output" label="TOML from your JSON" language="toml" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
