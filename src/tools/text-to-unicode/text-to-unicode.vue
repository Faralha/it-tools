<script setup lang="ts">
import { convertTextToUnicode, convertUnicodeToText } from './text-to-unicode.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputText = ref('');
const unicodeFromText = computed(() => inputText.value.trim() === '' ? '' : convertTextToUnicode(inputText.value));

const inputUnicode = ref('');
const textFromUnicode = computed(() => inputUnicode.value.trim() === '' ? '' : convertUnicodeToText(inputUnicode.value));

const textToUnicodeSnippetCode = `// Text to Unicode code points
const input = '{{input}}';
const unicode = [...input].map(c => 'U+' + c.codePointAt(0).toString(16).padStart(4, '0').toUpperCase()).join(' ');
console.log(unicode);
// {{output}}`;

const textToUnicodeSnippetVars = computed(() => ({
  input: inputText.value,
  output: unicodeFromText.value.slice(0, 60),
}));

const unicodeToTextSnippetCode = `// Unicode code points to text
const unicode = '{{input}}';
const text = unicode.split(' ').map(u => String.fromCodePoint(parseInt(u.replace('U+', ''), 16))).join('');
console.log(text);
// {{output}}`;

const unicodeToTextSnippetVars = computed(() => ({
  input: inputUnicode.value.slice(0, 60),
  output: textFromUnicode.value,
}));
</script>

<template>
  <c-card title="Text to Unicode">
    <c-input-text v-model:value="inputText" multiline placeholder="e.g. 'Hello Avengers'" label="Enter text to convert to unicode" autosize autofocus raw-text test-id="text-to-unicode-input" />
    <CodeSnippet :value="unicodeFromText" label="Unicode from your text" mt-2 test-id="text-to-unicode-output" />
    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="textToUnicodeSnippetCode" :variables="textToUnicodeSnippetVars" language="javascript" />
    </c-card>
  </c-card>

  <c-card title="Unicode to Text">
    <c-input-text v-model:value="inputUnicode" multiline placeholder="Input Unicode" label="Enter unicode to convert to text" autosize raw-text test-id="unicode-to-text-input" />
    <CodeSnippet :value="textFromUnicode" label="Text from your Unicode" mt-2 test-id="unicode-to-text-output" />
    <c-card title="Code snippet" mt-3>
      <CodeSnippet :code="unicodeToTextSnippetCode" :variables="unicodeToTextSnippetVars" language="javascript" />
    </c-card>
  </c-card>
</template>
