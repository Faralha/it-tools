<script setup lang="ts">
import InputCopyable from '../../components/InputCopyable.vue';
import { convertBase } from './integer-base-converter.model';
import { getErrorMessageIfThrows } from '@/utils/error';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputProps = {
  'labelPosition': 'left',
  'labelWidth': '170px',
  'labelAlign': 'right',
  'readonly': true,
  'mb-2': '',
} as const;

const input = ref('42');
const inputBase = ref(10);
const outputBase = ref(42);

function errorlessConvert(...args: Parameters<typeof convertBase>) {
  try {
    return convertBase(...args);
  }
  catch (err) {
    return '';
  }
}

const error = computed(() =>
  getErrorMessageIfThrows(() =>
    convertBase({ value: input.value, fromBase: inputBase.value, toBase: outputBase.value }),
  ),
);

const binaryOutput = computed(() => errorlessConvert({ value: input.value, fromBase: inputBase.value, toBase: 2 }));
const hexOutput = computed(() => errorlessConvert({ value: input.value, fromBase: inputBase.value, toBase: 16 }));

const snippetCode = `import { convertBase } from './integer-base-converter.model';

const value = '{{input}}';
const fromBase = {{fromBase}};

// Convert to binary (base 2)
const binary = convertBase({ value, fromBase, toBase: 2 });
console.log('Binary:', binary); // => {{binary}}

// Convert to hexadecimal (base 16)
const hex = convertBase({ value, fromBase, toBase: 16 });
console.log('Hex:', hex); // => {{hex}}

// Convert to any custom base
const custom = convertBase({ value, fromBase, toBase: 64 });`;

const snippetVars = computed(() => ({
  input: input.value.slice(0, 20),
  fromBase: String(inputBase.value),
  binary: binaryOutput.value.slice(0, 20),
  hex: hexOutput.value.slice(0, 20),
}));
</script>

<template>
  <div>
    <c-card>
      <c-input-text v-model:value="input" label="Input number" placeholder="Put your number here (ex: 42)" label-position="left" label-width="110px" mb-2 label-align="right" />
      <n-form-item label="Input base" label-placement="left" label-width="110" :show-feedback="false">
        <n-input-number v-model:value="inputBase" max="64" min="2" placeholder="Put your input base here (ex: 10)" w-full />
      </n-form-item>

      <n-alert v-if="error" style="margin-top: 25px" type="error">
        {{ error }}
      </n-alert>
      <n-divider />

      <InputCopyable
        label="Binary (2)"
        v-bind="inputProps"
        :value="errorlessConvert({ value: input, fromBase: inputBase, toBase: 2 })"
        placeholder="Binary version will be here..."
      />

      <InputCopyable
        label="Octal (8)"
        v-bind="inputProps"
        :value="errorlessConvert({ value: input, fromBase: inputBase, toBase: 8 })"
        placeholder="Octal version will be here..."
      />

      <InputCopyable
        label="Decimal (10)"
        v-bind="inputProps"
        :value="errorlessConvert({ value: input, fromBase: inputBase, toBase: 10 })"
        placeholder="Decimal version will be here..."
      />

      <InputCopyable
        label="Hexadecimal (16)"
        v-bind="inputProps"
        :value="errorlessConvert({ value: input, fromBase: inputBase, toBase: 16 })"
        placeholder="Hexadecimal version will be here..."
      />

      <InputCopyable
        label="Base64 (64)"
        v-bind="inputProps"
        :value="errorlessConvert({ value: input, fromBase: inputBase, toBase: 64 })"
        placeholder="Base64 version will be here..."
      />

      <div flex items-baseline>
        <n-input-group style="width: 160px; margin-right: 10px">
          <n-input-group-label> Custom: </n-input-group-label>
          <n-input-number v-model:value="outputBase" max="64" min="2" />
        </n-input-group>

        <InputCopyable
          flex-1
          v-bind="inputProps"
          :value="errorlessConvert({ value: input, fromBase: inputBase, toBase: outputBase })"
          :placeholder="`Base ${outputBase} will be here...`"
        />
      </div>
    </c-card>

    <c-card title="Code snippet" mt-5>
      <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
    </c-card>
  </div>
</template>

<style lang="less" scoped>
.n-input-group:not(:first-child) {
  margin-top: 5px;
}
</style>
