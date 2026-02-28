<script setup lang="ts">
import convert from 'xml-js';
import { isValidXML } from '../xml-formatter/xml-formatter.service';
import { withDefaultOnError } from '@/utils/defaults';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = '<a x="1.234" y="It\'s"/>';
const input = ref(defaultValue);
const output = computed(() => withDefaultOnError(() => JSON.stringify(convert.xml2js(input.value, { compact: true }), null, 2), ''));
const rules: UseValidationRule<string>[] = [
  {
    validator: isValidXML,
    message: 'Provided XML is not valid.',
  },
];

const snippetCode = `import convert from 'xml-js';

const xml = '{{input}}';

const json = JSON.stringify(convert.xml2js(xml, { compact: true }), null, 2);

console.log(json);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.slice(0, 60),
  output: output.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <c-input-text
    v-model:value="input" label="Your XML content" placeholder="Paste your XML content here..." rows="10"
    autosize raw-text multiline :validation-rules="rules" monospace
  />

  <CodeSnippet :value="output" label="Converted JSON" language="json" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
