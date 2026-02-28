<script setup lang="ts">
import { convertTextToUnicode, convertUnicodeToText } from './text-to-unicode.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputText = ref('');
const unicodeFromText = computed(() => inputText.value.trim() === '' ? '' : convertTextToUnicode(inputText.value));

const inputUnicode = ref('');
const textFromUnicode = computed(() => inputUnicode.value.trim() === '' ? '' : convertUnicodeToText(inputUnicode.value));
</script>

<template>
  <c-card title="Text to Unicode">
    <c-input-text v-model:value="inputText" multiline placeholder="e.g. 'Hello Avengers'" label="Enter text to convert to unicode" autosize autofocus raw-text test-id="text-to-unicode-input" />
    <CodeSnippet :value="unicodeFromText" label="Unicode from your text" mt-2 test-id="text-to-unicode-output" />
  </c-card>

  <c-card title="Unicode to Text">
    <c-input-text v-model:value="inputUnicode" multiline placeholder="Input Unicode" label="Enter unicode to convert to text" autosize raw-text test-id="unicode-to-text-input" />
    <CodeSnippet :value="textFromUnicode" label="Text from your Unicode" mt-2 test-id="unicode-to-text-output" />
  </c-card>
</template>
