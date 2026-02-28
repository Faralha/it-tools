<script setup lang="ts">
import { useStorage } from '@vueuse/core';
import { convert } from './list-converter.models';
import type { ConvertOptions } from './list-converter.types';
import CodeSnippet from '@/components/CodeSnippet.vue';

const sortOrderOptions = [
  { label: 'Sort ascending', value: 'asc', disabled: false },
  { label: 'Sort descending', value: 'desc', disabled: false },
];

const conversionConfig = useStorage<ConvertOptions>('list-converter:conversionConfig', {
  lowerCase: false,
  trimItems: true,
  removeDuplicates: true,
  keepLineBreaks: false,
  itemPrefix: '',
  itemSuffix: '',
  listPrefix: '',
  listSuffix: '',
  reverseList: false,
  sortList: null,
  separator: ', ',
});

const inputValue = ref('item1\nitem2\nitem3\nitem4');

const outputValue = computed(() => {
  try {
    return convert(inputValue.value, conversionConfig.value);
  }
  catch {
    return '';
  }
});

const snippetCode = `import { convert } from './list-converter.models';

const input = \`{{input}}\`;

const result = convert(input, {
  separator: '{{separator}}',
  trimItems: true,
  removeDuplicates: true,
  itemPrefix: '{{itemPrefix}}',
  itemSuffix: '{{itemSuffix}}',
});

console.log(result);
// => {{output}}`;

const snippetVars = computed(() => ({
  input: inputValue.value.replace(/\n/g, '\\n').slice(0, 50),
  separator: conversionConfig.value.separator,
  itemPrefix: conversionConfig.value.itemPrefix,
  itemSuffix: conversionConfig.value.itemSuffix,
  output: outputValue.value.replace(/\n/g, ' ').slice(0, 60),
}));
</script>

<template>
  <div style="flex: 0 0 100%">
    <div style="margin: 0 auto; max-width: 600px">
      <c-card>
        <div flex>
          <div>
            <n-form-item label="Trim list items" label-placement="left" label-width="150" :show-feedback="false" mb-2>
              <n-switch v-model:value="conversionConfig.trimItems" />
            </n-form-item>
            <n-form-item label="Remove duplicates" label-placement="left" label-width="150" :show-feedback="false" mb-2>
              <n-switch v-model:value="conversionConfig.removeDuplicates" data-test-id="removeDuplicates" />
            </n-form-item>
            <n-form-item label="Convert to lowercase" label-placement="left" label-width="150" :show-feedback="false" mb-2>
              <n-switch v-model:value="conversionConfig.lowerCase" />
            </n-form-item>
            <n-form-item label="Keep line breaks" label-placement="left" label-width="150" :show-feedback="false" mb-2>
              <n-switch v-model:value="conversionConfig.keepLineBreaks" />
            </n-form-item>
          </div>
          <div flex-1>
            <c-select
              v-model:value="conversionConfig.sortList"
              label="Sort list"
              label-position="left"
              label-width="120px"
              label-align="right"
              mb-2
              :options="sortOrderOptions"
              w-full
              :disabled="conversionConfig.reverseList"
              data-test-id="sortList"
              placeholder="Sort alphabetically"
            />

            <c-input-text
              v-model:value="conversionConfig.separator"
              label="Separator"
              label-position="left"
              label-width="120px"
              label-align="right"
              mb-2
              placeholder=","
            />

            <n-form-item label="Wrap item" label-placement="left" label-width="120" :show-feedback="false" mb-2>
              <c-input-text v-model:value="conversionConfig.itemPrefix" placeholder="Item prefix" test-id="itemPrefix" />
              <c-input-text v-model:value="conversionConfig.itemSuffix" placeholder="Item suffix" test-id="itemSuffix" />
            </n-form-item>
            <n-form-item label="Wrap list" label-placement="left" label-width="120" :show-feedback="false" mb-2>
              <c-input-text v-model:value="conversionConfig.listPrefix" placeholder="List prefix" test-id="listPrefix" />
              <c-input-text v-model:value="conversionConfig.listSuffix" placeholder="List suffix" test-id="listSuffix" />
            </n-form-item>
          </div>
        </div>
      </c-card>
    </div>
  </div>
  <format-transformer
    input-label="Your input data"
    input-placeholder="Paste your input data here..."
    output-label="Your transformed data"
    :transformer="(value) => convert(value, conversionConfig)"
  />

  <div style="margin: 16px auto; max-width: 600px">
    <c-card title="Code snippet">
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>
