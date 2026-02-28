<script setup lang="ts">
import { stringify } from 'yaml';
import JSON5 from 'json5';
import type { UseValidationRule } from '@/composable/validation';
import { isNotThrowing } from '@/utils/boolean';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const transformer = (value: string) => withDefaultOnError(() => stringify(JSON5.parse(value)), '');
const rules: UseValidationRule<string>[] = [
  {
    validator: (value: string) => value === '' || isNotThrowing(() => stringify(JSON5.parse(value))),
    message: 'Provided JSON is not valid.',
  },
];

const inputJson = ref('{"hello":"world","foo":42}');
const outputYaml = computed(() => withDefaultOnError(() => stringify(JSON5.parse(inputJson.value)), ''));

const snippetCode = `import { stringify } from 'yaml';
import JSON5 from 'json5';

const json = \{{input}}\;

const parsed = JSON5.parse(json);
const yaml   = stringify(parsed);

console.log(yaml);
// => {{output}}`;

const snippetVars = computed(() => ({
  input: inputJson.value.slice(0, 50),
  output: outputYaml.value.replace(/\n/g, ' ').slice(0, 60),
}));
</script>

<template>
  <format-transformer
    input-label="Your JSON"
    input-placeholder="Paste your JSON here..."
    output-label="YAML from your JSON"
    output-language="yaml"
    :input-validation-rules="rules"
    :transformer="transformer"
  />

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
