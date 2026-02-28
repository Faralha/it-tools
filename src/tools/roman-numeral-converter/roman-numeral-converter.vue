<script setup lang="ts">
import {
  MAX_ARABIC_TO_ROMAN,
  MIN_ARABIC_TO_ROMAN,
  arabicToRoman,
  isValidRomanNumber,
  romanToArabic,
} from './roman-numeral-converter.service';
import { useCopy } from '@/composable/copy';
import { useValidation } from '@/composable/validation';
import CodeSnippet from '@/components/CodeSnippet.vue';

const inputNumeral = ref(42);
const outputRoman = computed(() => arabicToRoman(inputNumeral.value));

const { attrs: validationNumeral } = useValidation({
  source: inputNumeral,
  rules: [
    {
      validator: value => value >= MIN_ARABIC_TO_ROMAN && value <= MAX_ARABIC_TO_ROMAN,
      message: `We can only convert numbers between ${MIN_ARABIC_TO_ROMAN.toLocaleString()} and ${MAX_ARABIC_TO_ROMAN.toLocaleString()}`,
    },
  ],
});

const inputRoman = ref('XLII');
const outputNumeral = computed(() => romanToArabic(inputRoman.value));

const validationRoman = useValidation({
  source: inputRoman,
  rules: [
    {
      validator: value => isValidRomanNumber(value),
      message: 'The input you entered is not a valid roman number',
    },
  ],
});

const { copy: copyRoman } = useCopy({ source: outputRoman, text: 'Roman number copied to the clipboard' });
const { copy: copyArabic } = useCopy({ source: () => String(outputNumeral), text: 'Arabic number copied to the clipboard' });

const arabicToRomanSnippetCode = `import { arabicToRoman } from './roman-numeral-converter.service';

const input = {{input}};
const roman = arabicToRoman(input);

console.log(roman);
// => {{output}}`;

const arabicToRomanSnippetVars = computed(() => ({
  input: String(inputNumeral.value),
  output: outputRoman.value,
}));

const romanToArabicSnippetCode = `import { romanToArabic } from './roman-numeral-converter.service';

const input = '{{input}}';
const arabic = romanToArabic(input);

console.log(arabic);
// => {{output}}`;

const romanToArabicSnippetVars = computed(() => ({
  input: inputRoman.value,
  output: String(outputNumeral.value),
}));
</script>

<template>
  <div>
    <c-card title="Arabic to roman">
      <div flex items-center justify-between>
        <n-form-item v-bind="validationNumeral as any">
          <n-input-number v-model:value="inputNumeral" :min="1" style="width: 200px" :show-button="false" />
        </n-form-item>
        <div class="result">
          {{ outputRoman }}
        </div>
        <c-button autofocus :disabled="validationNumeral.validationStatus === 'error'" @click="copyRoman()">
          Copy
        </c-button>
      </div>
      <c-card title="Code snippet" mt-3>
        <CodeSnippet :code="arabicToRomanSnippetCode" :variables="arabicToRomanSnippetVars" language="javascript" />
      </c-card>
    </c-card>
    <c-card title="Roman to arabic" mt-5>
      <div flex items-center justify-between>
        <c-input-text v-model:value="inputRoman" style="width: 200px" :validation="validationRoman" />

        <div class="result">
          {{ outputNumeral }}
        </div>
        <c-button :disabled="!validationRoman.isValid" @click="copyArabic()">
          Copy
        </c-button>
      </div>
      <c-card title="Code snippet" mt-3>
        <CodeSnippet :code="romanToArabicSnippetCode" :variables="romanToArabicSnippetVars" language="javascript" />
      </c-card>
    </c-card>
  </div>
</template>

<style lang="less" scoped>
.result {
  font-size: 22px;
}
</style>
