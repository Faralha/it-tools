<script setup lang="ts">
import { evaluate } from 'mathjs';
import { withDefaultOnError } from '@/utils/defaults';
import CodeSnippet from '@/components/CodeSnippet.vue';

const expression = ref('');

const result = computed(() => withDefaultOnError(() => String(evaluate(expression.value) ?? ''), ''));

const snippetCode = `import { evaluate } from 'mathjs';

const expression = '{{input}}';
const result = evaluate(expression);

console.log(result);
// => {{output}}`;

const snippetVars = computed(() => ({
  input: expression.value,
  output: result.value,
}));
</script>

<template>
  <div>
    <c-input-text
      v-model:value="expression"
      rows="1"
      multiline
      placeholder="Your math expression (ex: 2*sqrt(6) )..."
      raw-text
      monospace
      autofocus
      autosize
    />

    <c-card v-if="result !== ''" title="Result" mt-5>
      {{ result }}
    </c-card>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
