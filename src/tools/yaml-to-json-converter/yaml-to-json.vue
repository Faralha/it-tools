<script setup lang="ts">
import { parse as parseYaml } from 'yaml';
import type { UseValidationRule } from '@/composable/validation';
import { isNotThrowing } from '@/utils/boolean';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = 'name: Alice\nage: 30';
const input = ref(defaultValue);
const output = computed(() => withDefaultOnError(() => {
  const obj = parseYaml(input.value, { merge: true });
  return obj ? JSON.stringify(obj, null, 3) : '';
}, ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: (value: string) => isNotThrowing(() => parseYaml(value)),
    message: 'Provided YAML is not valid.',
  },
];

const snippetCode = `import { parse as parseYaml } from 'yaml';

const yaml = '{{input}}';

const json = JSON.stringify(parseYaml(yaml, { merge: true }), null, 3);

console.log(json);
/* {{output}} */`;

const snippetVars = computed(() => ({
  input: input.value.replace(/\n/g, '\\n').slice(0, 60),
  output: output.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your YAML" placeholder="Paste your yaml here..." rows="10" autosize
    raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="JSON from your YAML" language="json" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
