<script setup lang="ts">
import { parse as parseYaml } from 'yaml';
import { stringify as stringifyToml } from 'iarna-toml-esm';
import { withDefaultOnError } from '../../utils/defaults';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = 'name: Alice\nage: 30';
const input = ref(defaultValue);
const output = computed(() => input.value.trim() === '' ? '' : withDefaultOnError(() => stringifyToml(parseYaml(input.value) as any), ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => {
      try {
        if (v.trim()) {
          parseYaml(v);
        }
        return true;
      }
      catch { return false; }
    },
    message: 'Provided YAML is not valid.',
  },
];

const snippetCode = `import { parse as parseYaml } from 'yaml';
import { stringify as stringifyToml } from 'iarna-toml-esm';

const yaml = \`{{input}}\`;

const toml = stringifyToml(parseYaml(yaml));

console.log(toml);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.replace(/\n/g, '\\n').slice(0, 60),
  output: output.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your YAML" placeholder="Paste your YAML here..." rows="10" autosize
    raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="TOML from your YAML" language="toml" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
