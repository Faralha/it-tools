<script setup lang="ts">
import { codesByCategories } from './http-status-codes.constants';
import { useFuzzySearch } from '@/composable/fuzzySearch';
import CodeSnippet from '@/components/CodeSnippet.vue';

const search = ref('');

const { searchResult } = useFuzzySearch({
  search,
  data: codesByCategories.flatMap(({ codes, category }) => codes.map(code => ({ ...code, category }))),
  options: {
    keys: [{ name: 'code', weight: 3 }, { name: 'name', weight: 2 }, 'description', 'category'],
  },
});

const codesByCategoryFiltered = computed(() => {
  if (!search.value) {
    return codesByCategories;
  }

  return [{ category: 'Search results', codes: searchResult.value }];
});

const snippetCode = `// Check HTTP response status codes
const response = await fetch('{{url}}');

if (response.status === 200) {
  // OK - request succeeded
} else if (response.status === {{code}}) {
  // {{name}}: {{description}}
}

console.log(response.status); // => {{code}}`;

const snippetVars = computed(() => {
  const firstResult = searchResult.value[0] ?? { code: 404, name: 'Not Found', description: 'The server cannot find the requested resource.' };
  return {
    url: 'https://api.example.com/data',
    code: String(firstResult.code ?? 404),
    name: String(firstResult.name ?? 'Not Found'),
    description: String((firstResult as any).description ?? '').slice(0, 60),
  };
});
</script>

<template>
  <div>
    <c-input-text v-model:value="search" placeholder="Search http status..." autofocus raw-text mb-10 />

    <div v-for="{ codes, category } of codesByCategoryFiltered" :key="category" mb-8>
      <div mb-2 text-xl>
        {{ category }}
      </div>

      <c-card v-for="{ code, description, name, type } of codes" :key="code" mb-2>
        <div text-lg font-bold>
          {{ code }} {{ name }}
        </div>
        <div op-70>
          {{ description }} {{ type !== 'HTTP' ? `For ${type}.` : '' }}
        </div>
      </c-card>
    </div>
  </div>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
