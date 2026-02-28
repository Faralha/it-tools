<script setup lang="ts">
import { formatXml, isValidXML } from './xml-formatter.service';
import type { UseValidationRule } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const defaultValue = '<hello><world>foo</world><world>bar</world></hello>';
const indentSize = useStorage('xml-formatter:indent-size', 2);
const collapseContent = useStorage('xml-formatter:collapse-content', true);
const input = ref(defaultValue);

const output = computed(() =>
  input.value.trim() === ''
    ? ''
    : formatXml(input.value, {
      indentation: ' '.repeat(indentSize.value),
      collapseContent: collapseContent.value,
      lineSeparator: '\n',
    }),
);

const rules: UseValidationRule<string>[] = [
  {
    validator: isValidXML,
    message: 'Provided XML is not valid.',
  },
];

const snippetCode = `import { XMLFormatter } from 'xml-formatter';

const input = '{{input}}';

const formatted = XMLFormatter(input, {
  indentation: '  ',
  collapseContent: true,
  lineSeparator: '\\n',
});

console.log(formatted);
// {{output}}`;

const snippetVars = computed(() => ({
  input: input.value.slice(0, 80),
  output: output.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <div important:flex-full important:flex-shrink-0 important:flex-grow-0>
    <div flex justify-center>
      <n-form-item label="Collapse content:" label-placement="left">
        <n-switch v-model:value="collapseContent" />
      </n-form-item>
      <n-form-item label="Indent size:" label-placement="left" label-width="100" :show-feedback="false">
        <n-input-number v-model:value="indentSize" min="0" max="10" w-100px />
      </n-form-item>
    </div>
  </div>

  <c-input-text
    v-model:value="input"
    label="Your XML"
    placeholder="Paste your XML here..."
    rows="10"
    autosize
    raw-text
    multiline
    :validation-rules="rules"
    monospace
  />

  <CodeSnippet :value="output" label="Formatted XML" language="xml" />

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
