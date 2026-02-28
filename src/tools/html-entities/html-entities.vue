<script setup lang="ts">
import { escape, unescape } from 'lodash';
import CodeSnippet from '@/components/CodeSnippet.vue';

const escapeInput = ref('<title>IT Tool</title>');
const escapeOutput = computed(() => escape(escapeInput.value));

const unescapeInput = ref('&lt;title&gt;IT Tool&lt;/title&gt;');
const unescapeOutput = computed(() => unescape(unescapeInput.value));

const escapeSnippetCode = `import { escape } from 'lodash';

const input = "{{input}}";

const escaped = escape(input);

console.log(escaped);
// => "{{output}}"`;

const escapeSnippetVars = computed(() => ({
  input: escapeInput.value,
  output: escapeOutput.value,
}));

const unescapeSnippetCode = `import { unescape } from 'lodash';

const input = "{{input}}";

const unescaped = unescape(input);

console.log(unescaped);
// => "{{output}}"`;

const unescapeSnippetVars = computed(() => ({
  input: unescapeInput.value,
  output: unescapeOutput.value,
}));
</script>

<template>
  <c-card title="Escape html entities">
    <n-form-item label="Your string :">
      <c-input-text
        v-model:value="escapeInput" multiline placeholder="The string to escape" rows="3" autosize
        raw-text
      />
    </n-form-item>

    <CodeSnippet :value="escapeOutput" label="Your string escaped :" />
  </c-card>

  <c-card title="Code snippet — Escape">
    <CodeSnippet :code="escapeSnippetCode" :variables="escapeSnippetVars" language="javascript" />
  </c-card>

  <c-card title="Unescape html entities">
    <n-form-item label="Your escaped string :">
      <c-input-text
        v-model:value="unescapeInput" multiline placeholder="The string to unescape" rows="3" autosize
        raw-text
      />
    </n-form-item>

    <CodeSnippet :value="unescapeOutput" label="Your string unescaped :" />
  </c-card>

  <c-card title="Code snippet — Unescape">
    <CodeSnippet :code="unescapeSnippetCode" :variables="unescapeSnippetVars" language="javascript" />
  </c-card>
</template>
