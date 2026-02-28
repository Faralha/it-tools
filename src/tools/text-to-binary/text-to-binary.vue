<script setup lang="ts">
import { convertAsciiBinaryToText, convertTextToAsciiBinary } from './text-to-binary.models';
import { withDefaultOnError } from '@/utils/defaults';
import { isNotThrowing } from '@/utils/boolean';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputText = ref('');
const binaryFromText = computed(() => convertTextToAsciiBinary(inputText.value));

const inputBinary = ref('');
const textFromBinary = computed(() => withDefaultOnError(() => convertAsciiBinaryToText(inputBinary.value), ''));
const inputBinaryValidationRules = [
  {
    validator: (value: string) => isNotThrowing(() => convertAsciiBinaryToText(value)),
    message: 'Binary should be a valid ASCII binary string with multiples of 8 bits',
  },
];

const textToBinSnippetCode = `// Text to ASCII binary
const input = '{{input}}';
const binary = input.split('').map(c => c.charCodeAt(0).toString(2).padStart(8, '0')).join(' ');
console.log(binary);
// {{output}}`;

const textToBinSnippetVars = computed(() => ({
  input: inputText.value,
  output: binaryFromText.value.slice(0, 60),
}));

const binToTextSnippetCode = `// ASCII binary to text
const binary = '{{input}}';
const text = binary.split(' ').map(b => String.fromCharCode(parseInt(b, 2))).join('');
console.log(text);
// {{output}}`;

const binToTextSnippetVars = computed(() => ({
  input: inputBinary.value.slice(0, 60),
  output: textFromBinary.value,
}));
</script>

<template>
  <c-card title="Text to ASCII binary">
    <c-input-text v-model:value="inputText" multiline placeholder="e.g. 'Hello world'" label="Enter text to convert to binary" autosize autofocus raw-text test-id="text-to-binary-input" />
    <CodeSnippet :value="binaryFromText" label="Binary from your text" mt-2 test-id="text-to-binary-output" />
    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="textToBinSnippetCode" :variables="textToBinSnippetVars" language="javascript" />
    </c-card>
  </c-card>

  <c-card title="ASCII binary to text">
    <c-input-text v-model:value="inputBinary" multiline placeholder="e.g. '01001000 01100101 01101100 01101100 01101111'" label="Enter binary to convert to text" autosize raw-text :validation-rules="inputBinaryValidationRules" test-id="binary-to-text-input" />
    <CodeSnippet :value="textFromBinary" label="Text from your binary" mt-2 test-id="binary-to-text-output" />
    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="binToTextSnippetCode" :variables="binToTextSnippetVars" language="javascript" />
    </c-card>
  </c-card>
</template>
