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
</script>

<template>
  <c-card title="Text to ASCII binary">
    <c-input-text v-model:value="inputText" multiline placeholder="e.g. 'Hello world'" label="Enter text to convert to binary" autosize autofocus raw-text test-id="text-to-binary-input" />
    <CodeSnippet :value="binaryFromText" label="Binary from your text" mt-2 test-id="text-to-binary-output" />
  </c-card>

  <c-card title="ASCII binary to text">
    <c-input-text v-model:value="inputBinary" multiline placeholder="e.g. '01001000 01100101 01101100 01101100 01101111'" label="Enter binary to convert to text" autosize raw-text :validation-rules="inputBinaryValidationRules" test-id="binary-to-text-input" />
    <CodeSnippet :value="textFromBinary" label="Text from your binary" mt-2 test-id="binary-to-text-output" />
  </c-card>
</template>
