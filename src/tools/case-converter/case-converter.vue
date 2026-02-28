<script setup lang="ts">
import {
  camelCase,
  capitalCase,
  constantCase,
  dotCase,
  headerCase,
  noCase,
  paramCase,
  pascalCase,
  pathCase,
  sentenceCase,
  snakeCase,
} from 'change-case';
import InputCopyable from '../../components/InputCopyable.vue';
import CodeSnippet from '@/components/CodeSnippet.vue';

const baseConfig = {
  stripRegexp: /[^A-Za-zÀ-ÖØ-öø-ÿ]+/gi,
};

const input = ref('lorem ipsum dolor sit amet');

const formats = computed(() => [
  {
    label: 'Lowercase:',
    value: input.value.toLocaleLowerCase(),
  },
  {
    label: 'Uppercase:',
    value: input.value.toLocaleUpperCase(),
  },
  {
    label: 'Camelcase:',
    value: camelCase(input.value, baseConfig),
  },
  {
    label: 'Capitalcase:',
    value: capitalCase(input.value, baseConfig),
  },
  {
    label: 'Constantcase:',
    value: constantCase(input.value, baseConfig),
  },
  {
    label: 'Dotcase:',
    value: dotCase(input.value, baseConfig),
  },
  {
    label: 'Headercase:',
    value: headerCase(input.value, baseConfig),
  },
  {
    label: 'Nocase:',
    value: noCase(input.value, baseConfig),
  },
  {
    label: 'Paramcase:',
    value: paramCase(input.value, baseConfig),
  },
  {
    label: 'Pascalcase:',
    value: pascalCase(input.value, baseConfig),
  },
  {
    label: 'Pathcase:',
    value: pathCase(input.value, baseConfig),
  },
  {
    label: 'Sentencecase:',
    value: sentenceCase(input.value, baseConfig),
  },
  {
    label: 'Snakecase:',
    value: snakeCase(input.value, baseConfig),
  },
  {
    label: 'Mockingcase:',
    value: input.value
      .split('')
      .map((char, index) => (index % 2 === 0 ? char.toUpperCase() : char.toLowerCase()))
      .join(''),
  },
]);

const inputLabelAlignmentConfig = {
  labelPosition: 'left',
  labelWidth: '120px',
  labelAlign: 'right',
};

const snippetCode = `import { camelCase, snakeCase, pascalCase, kebabCase } from 'change-case';

const input = "{{input}}";

console.log(camelCase(input));   // => "{{camelCase}}"
console.log(snakeCase(input));   // => "{{snakeCase}}"
console.log(pascalCase(input));  // => "{{pascalCase}}"
console.log(kebabCase(input));   // => "{{kebabCase}}"`;

const snippetVars = computed(() => ({
  input: input.value,
  camelCase: camelCase(input.value, baseConfig),
  snakeCase: snakeCase(input.value, baseConfig),
  pascalCase: pascalCase(input.value, baseConfig),
  kebabCase: paramCase(input.value, baseConfig),
}));
</script>

<template>
  <c-card>
    <c-input-text
      v-model:value="input" label="Your string:" placeholder="Your string..." raw-text
      v-bind="inputLabelAlignmentConfig"
    />

    <div my-16px divider />

    <InputCopyable
      v-for="format in formats" :key="format.label" :value="format.value" :label="format.label"
      v-bind="inputLabelAlignmentConfig" mb-1
    />
  </c-card>

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
