<script setup lang="ts">
import { useThemeVars } from 'naive-ui';

import type { Group, Scope } from './chmod-calculator.types';
import { computeChmodOctalRepresentation, computeChmodSymbolicRepresentation } from './chmod-calculator.service';
import CodeSnippet from '@/components/CodeSnippet.vue';

const themeVars = useThemeVars();

const scopes: { scope: Scope; title: string }[] = [
  { scope: 'read', title: 'Read (4)' },
  { scope: 'write', title: 'Write (2)' },
  { scope: 'execute', title: 'Execute (1)' },
];
const groups: Group[] = ['owner', 'group', 'public'];

const permissions = ref({
  owner: { read: false, write: false, execute: false },
  group: { read: false, write: false, execute: false },
  public: { read: false, write: false, execute: false },
});

const octal = computed(() => computeChmodOctalRepresentation({ permissions: permissions.value }));
const symbolic = computed(() => computeChmodSymbolicRepresentation({ permissions: permissions.value }));

const snippetCode = `// Compute chmod octal from permissions
const toOctal = (r, w, x) => (r ? 4 : 0) + (w ? 2 : 0) + (x ? 1 : 0);

const ownerRWX  = [{{ownerR}}, {{ownerW}}, {{ownerX}}];
const groupRWX  = [{{groupR}}, {{groupW}}, {{groupX}}];
const publicRWX = [{{pubR}},   {{pubW}},   {{pubX}}];

const octal = [
  toOctal(...ownerRWX),
  toOctal(...groupRWX),
  toOctal(...publicRWX),
].join('');

console.log(octal);
// => "{{output}}"
console.log(\`chmod ${octal} path\`);`;

const snippetVars = computed(() => ({
  ownerR: String(permissions.value.owner.read),
  ownerW: String(permissions.value.owner.write),
  ownerX: String(permissions.value.owner.execute),
  groupR: String(permissions.value.group.read),
  groupW: String(permissions.value.group.write),
  groupX: String(permissions.value.group.execute),
  pubR: String(permissions.value.public.read),
  pubW: String(permissions.value.public.write),
  pubX: String(permissions.value.public.execute),
  output: octal.value,
}));
</script>

<template>
  <div>
    <n-table :bordered="false" :bottom-bordered="false" single-column class="permission-table">
      <thead>
        <tr>
          <th class="text-center" scope="col" />
          <th class="text-center" scope="col">
            Owner (u)
          </th>
          <th class="text-center" scope="col">
            Group (g)
          </th>
          <th class="text-center" scope="col">
            Public (o)
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="{ scope, title } of scopes" :key="scope">
          <td class="line-header">
            {{ title }}
          </td>
          <td v-for="group of groups" :key="group" class="text-center">
            <!-- <n-switch v-model:value="permissions[group][scope]" /> -->
            <n-checkbox v-model:checked="permissions[group][scope]" size="large" />
          </td>
        </tr>
      </tbody>
    </n-table>

    <div class="octal-result">
      {{ octal }}
    </div>
    <div class="octal-result">
      {{ symbolic }}
    </div>

    <CodeSnippet :value="`chmod ${octal} path`" />
  </div>

  <c-card title="Code snippet">
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>

<style lang="less" scoped>
.octal-result {
  text-align: center;
  font-size: 50px;
  font-family: monospace;
  color: v-bind('themeVars.primaryColor');
  margin: 20px 0;
}

.permission-table {

  td,
  th {
    padding: 15px;

    @media screen and (max-width: 600px) {
      padding: 5px;
    }
  }
}

.line-header {
  font-weight: bold;
  text-align: right;
  max-width: 80px;
}

.text-center {
  text-align: center;
}
</style>
