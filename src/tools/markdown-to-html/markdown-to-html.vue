<script setup lang="ts">
import markdownit from 'markdown-it';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputMarkdown = ref('');
const outputHtml = computed(() => {
  const md = markdownit();
  return md.render(inputMarkdown.value);
});

function printHtml() {
  const w = window.open();
  if (w === null) {
    return;
  }
  w.document.body.innerHTML = outputHtml.value;
  w.print();
}

const snippetCode = `import markdownit from 'markdown-it';

const md = markdownit();

const input = \`{{input}}\`;

const html = md.render(input);

console.log(html);
// {{output}}`;

const snippetVars = computed(() => ({
  input: inputMarkdown.value.replace(/`/g, '\\`').slice(0, 60),
  output: outputHtml.value.replace(/\n/g, ' ').slice(0, 80),
}));
</script>

<template>
  <div>
    <c-input-text
      v-model:value="inputMarkdown"
      multiline raw-text
      placeholder="Your Markdown content..."
      rows="8"
      autofocus
      label="Your Markdown to convert:"
    />

    <n-divider />

    <n-form-item label="Output HTML:">
      <CodeSnippet :value="outputHtml" :word-wrap="true" language="html" />
    </n-form-item>

    <div flex justify-center>
      <n-button @click="printHtml">
        Print as PDF
      </n-button>
    </div>

    <c-card title="Code snippet">
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
