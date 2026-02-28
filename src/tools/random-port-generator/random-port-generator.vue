<script setup lang="ts">
import { generatePort } from './random-port-generator.model';
import { computedRefreshable } from '@/composable/computedRefreshable';
import { useCopy } from '@/composable/copy';
import CodeSnippet from '@/components/CodeSnippet.vue';

const [port, refreshPort] = computedRefreshable(() => String(generatePort()));

const { copy } = useCopy({ source: port, text: 'Port copied to the clipboard' });

const snippetCode = `// Generate a random unregistered port (1024-65535)
function generatePort(min = 1024, max = 65535) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

const port = generatePort();
console.log(port);
// => {{output}}`;

const snippetVars = computed(() => ({
  output: port.value,
}));
</script>

<template>
  <c-card>
    <div class="port">
      {{ port }}
    </div>
    <div flex justify-center gap-3>
      <c-button @click="copy()">
        Copy
      </c-button>
      <c-button @click="refreshPort">
        Refresh
      </c-button>
    </div>
  </c-card>

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>

<style lang="less" scoped>
.port {
  text-align: center;
  font-size: 26px;
  font-weight: 400;
  margin: 10px 0 25px;
}
</style>
