<script setup lang="ts">
import { useObfuscateString } from './string-obfuscator.model';
import { useCopy } from '@/composable/copy';
import CodeSnippet from '@/components/CodeSnippet.vue';

const str = ref('Lorem ipsum dolor sit amet');
const keepFirst = ref(4);
const keepLast = ref(4);
const keepSpace = ref(true);

const obfuscatedString = useObfuscateString(str, { keepFirst, keepLast, keepSpace });
const { copy } = useCopy({ source: obfuscatedString });

const snippetCode = `// Obfuscate a string, keeping first and last N characters
function obfuscate(str, keepFirst = 4, keepLast = 4, keepSpace = true) {
  if (str.length <= keepFirst + keepLast) return str;
  const start = str.slice(0, keepFirst);
  const end = str.slice(-keepLast);
  const middle = str.slice(keepFirst, str.length - keepLast)
    .split('')
    .map(c => (keepSpace && c === ' ') ? ' ' : '*')
    .join('');
  return start + middle + end;
}

const input = '{{input}}';
const output = obfuscate(input, {{keepFirst}}, {{keepLast}});
console.log(output);
// => {{output}}`;

const snippetVars = computed(() => ({
  input: str.value,
  keepFirst: String(keepFirst.value),
  keepLast: String(keepLast.value),
  output: obfuscatedString.value,
}));
</script>

<template>
  <div>
    <c-input-text v-model:value="str" raw-text placeholder="Enter string to obfuscate" label="String to obfuscate:" clearable multiline />

    <div mt-4 flex gap-10px>
      <div>
        <div>Keep first:</div>
        <n-input-number v-model:value="keepFirst" min="0" />
      </div>

      <div>
        <div>Keep last:</div>
        <n-input-number v-model:value="keepLast" min="0" />
      </div>

      <div>
        <div mb-5px>
          Keep&nbsp;spaces:
        </div>
        <n-switch v-model:value="keepSpace" />
      </div>
    </div>

    <c-card v-if="obfuscatedString" mt-60px max-w-600px flex items-center gap-5px font-mono>
      <div break-anywhere text-wrap>
        {{ obfuscatedString }}
      </div>

      <c-button @click="copy()">
        <icon-mdi:content-copy />
      </c-button>
    </c-card>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
