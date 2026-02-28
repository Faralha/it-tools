<script setup lang="ts">
import { parse as parseToml } from 'iarna-toml-esm';
import { withDefaultOnError } from '../../utils/defaults';
import { isValidToml } from './toml.services';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = 'name = "Alice"\nage = 30';
const input = ref(defaultValue);
const output = computed(() => input.value.trim() === '' ? '' : withDefaultOnError(() => JSON.stringify(parseToml(input.value), null, 3), ''));
const rules: UseValidationRule<string>[] = [
  { validator: isValidToml, message: 'Provided TOML is not valid.' },
];

const snippetCode = `import { parse as parseToml } from 'iarna-toml-esm';

const toml = \`{{input}}\`;

const json = JSON.stringify(parseToml(toml), null, 3);

console.log(json);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.replace(/\n/g, '\\n').slice(0, 60),
  output: output.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input"
    label="Your TOML"
    placeholder="Paste your TOML here..."
    rows="10"
    autosize
    raw-text
    multiline
    :validation-rules="rules"
    monospace
  />

  <CodeSnippet :value="output" label="JSON from your TOML" language="json" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
