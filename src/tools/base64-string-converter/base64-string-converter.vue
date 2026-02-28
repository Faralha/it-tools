<script setup lang="ts">
import CodeSnippet from '@/components/CodeSnippet.vue';
import { base64ToText, isValidBase64, textToBase64 } from '@/utils/base64';
import { withDefaultOnError } from '@/utils/defaults';

const encodeUrlSafe = useStorage('base64-string-converter--encode-url-safe', false);
const decodeUrlSafe = useStorage('base64-string-converter--decode-url-safe', false);

const textInput = ref('');
const base64Output = computed(() => textToBase64(textInput.value, { makeUrlSafe: encodeUrlSafe.value }));

const base64Input = ref('');
const textOutput = computed(() =>
  withDefaultOnError(() => base64ToText(base64Input.value.trim(), { makeUrlSafe: decodeUrlSafe.value }), ''),
);
const b64ValidationRules = [
  {
    message: 'Invalid base64 string',
    validator: (value: string) => isValidBase64(value.trim(), { makeUrlSafe: decodeUrlSafe.value }),
  },
];
const b64ValidationWatch = [decodeUrlSafe];

const encodeSnippetCode = `import { Base64 } from 'js-base64';

const input = "{{input}}";
const urlSafe = {{urlSafe}};

const output = urlSafe
  ? Base64.encodeURI(input)
  : Base64.encode(input);

console.log(output);
// => "{{output}}"`;

const encodeSnippetVars = computed(() => ({
  input: textInput.value,
  urlSafe: String(encodeUrlSafe.value),
  output: base64Output.value,
}));

const decodeSnippetCode = `import { Base64 } from 'js-base64';

const input = "{{input}}";
const urlSafe = {{urlSafe}};

const output = urlSafe
  ? Base64.decode(input.replace(/-/g, '+').replace(/_/g, '/'))
  : Base64.decode(input);

console.log(output);
// => "{{output}}"`;

const decodeSnippetVars = computed(() => ({
  input: base64Input.value,
  urlSafe: String(decodeUrlSafe.value),
  output: textOutput.value,
}));
</script>

<template>
  <c-card title="String to base64">
    <n-form-item label="Encode URL safe" label-placement="left">
      <n-switch v-model:value="encodeUrlSafe" />
    </n-form-item>
    <c-input-text
      v-model:value="textInput" multiline placeholder="Put your string here..." rows="5"
      label="String to encode" raw-text mb-5
    />

    <CodeSnippet
      :value="base64Output"
      label="Base64 of string"
      copy-message="Base64 string copied to the clipboard"
    />
  </c-card>

  <c-card title="Code snippet — Encode">
    <code-snippet :code="encodeSnippetCode" :variables="encodeSnippetVars" language="javascript" />
  </c-card>

  <c-card title="Base64 to string">
    <n-form-item label="Decode URL safe" label-placement="left">
      <n-switch v-model:value="decodeUrlSafe" />
    </n-form-item>
    <c-input-text
      v-model:value="base64Input" multiline placeholder="Your base64 string..." rows="5"
      :validation-rules="b64ValidationRules" :validation-watch="b64ValidationWatch" label="Base64 string to decode"
      mb-5
    />

    <CodeSnippet
      :value="textOutput"
      label="Decoded string"
      copy-message="String copied to the clipboard"
    />
  </c-card>

  <c-card title="Code snippet — Decode">
    <code-snippet :code="decodeSnippetCode" :variables="decodeSnippetVars" language="javascript" />
  </c-card>
</template>
