<script setup lang="ts">
import { parse as parseToml } from 'iarna-toml-esm';
import { stringify as stringifyToYaml } from 'yaml';
import { withDefaultOnError } from '../../utils/defaults';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = 'name = "Alice"\nage = 30';
const input = ref(defaultValue);
const output = computed(() => input.value.trim() === '' ? '' : withDefaultOnError(() => stringifyToYaml(parseToml(input.value)), ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: (v: string) => {
      try {
        if (v.trim()) {
          parseToml(v);
        }
        return true;
      }
      catch { return false; }
    },
    message: 'Provided TOML is not valid.',
  },
];

const snippetCode = `import { parse as parseToml } from 'iarna-toml-esm';
import { stringify as stringifyToYaml } from 'yaml';

const toml = \`{{input}}\`;

const yaml = stringifyToYaml(parseToml(toml));

console.log(yaml);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.replace(/\n/g, '\\n').slice(0, 60),
  output: output.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your TOML" placeholder="Paste your TOML here..." rows="10" autosize
    raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="YAML from your TOML" language="yaml" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
