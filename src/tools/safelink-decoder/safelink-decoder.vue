<script setup lang="ts">
import { decodeSafeLinksURL } from './safelink-decoder.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputSafeLinkUrl = ref('');
const outputDecodedUrl = computed(() => {
  try {
    return decodeSafeLinksURL(inputSafeLinkUrl.value);
  }
  catch (e: any) {
    return e.toString();
  }
});

const snippetCode = `import { decodeSafeLinksURL } from './safelink-decoder.service';

const url = '{{input}}';

const decoded = decodeSafeLinksURL(url);

console.log(decoded);
// {{output}}`;

const snippetVars = computed(() => ({
  input: inputSafeLinkUrl.value.slice(0, 80),
  output: outputDecodedUrl.value.slice(0, 80),
}));
</script>

<template>
  <div>
    <c-input-text
      v-model:value="inputSafeLinkUrl"
      raw-text
      placeholder="Your input Outlook SafeLink Url..."
      autofocus
      label="Your input Outlook SafeLink Url:"
    />

    <n-divider />

    <n-form-item label="Output decoded URL:">
      <CodeSnippet :value="outputDecodedUrl" :word-wrap="true" />
    </n-form-item>

    <c-card title="Code snippet">
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
