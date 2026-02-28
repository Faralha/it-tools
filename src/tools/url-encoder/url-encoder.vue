<script setup lang="ts">
import { useValidation } from '@/composable/validation';
import { isNotThrowing } from '@/utils/boolean';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const encodeInput = ref('Hello world :)');
const encodeOutput = computed(() => withDefaultOnError(() => encodeURIComponent(encodeInput.value), ''));
const encodedValidation = useValidation({
  source: encodeInput,
  rules: [
    {
      validator: value => isNotThrowing(() => encodeURIComponent(value)),
      message: 'Impossible to parse this string',
    },
  ],
});

const decodeInput = ref('Hello%20world%20%3A)');
const decodeOutput = computed(() => withDefaultOnError(() => decodeURIComponent(decodeInput.value), ''));
const decodeValidation = useValidation({
  source: decodeInput,
  rules: [
    {
      validator: value => isNotThrowing(() => decodeURIComponent(value)),
      message: 'Impossible to parse this string',
    },
  ],
});

const encodeSnippetCode = `// Encode URI component
const input = '{{input}}';
const encoded = encodeURIComponent(input);
console.log(encoded);
// {{output}}`;

const encodeSnippetVars = computed(() => ({
  input: encodeInput.value,
  output: encodeOutput.value,
}));

const decodeSnippetCode = `// Decode URI component
const input = '{{input}}';
const decoded = decodeURIComponent(input);
console.log(decoded);
// {{output}}`;

const decodeSnippetVars = computed(() => ({
  input: decodeInput.value,
  output: decodeOutput.value,
}));
</script>

<template>
  <c-card title="Encode">
    <c-input-text
      v-model:value="encodeInput"
      label="Your string :"
      :validation="encodedValidation"
      multiline
      autosize
      placeholder="The string to encode"
      rows="2"
      mb-3
    />

    <CodeSnippet :value="encodeOutput" label="Your string encoded :" copy-message="Encoded string copied to the clipboard" />

    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="encodeSnippetCode" :variables="encodeSnippetVars" language="javascript" />
    </c-card>
  </c-card>
  <c-card title="Decode">
    <c-input-text
      v-model:value="decodeInput"
      label="Your encoded string :"
      :validation="decodeValidation"
      multiline
      autosize
      placeholder="The string to decode"
      rows="2"
      mb-3
    />

    <CodeSnippet :value="decodeOutput" label="Your string decoded :" copy-message="Decoded string copied to the clipboard" />

    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="decodeSnippetCode" :variables="decodeSnippetVars" language="javascript" />
    </c-card>
  </c-card>
</template>
