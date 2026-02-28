<script setup lang="ts">
import { useThemeVars } from 'naive-ui';
import Memo from './git-memo.content.md';
import CodeSnippet from '@/components/CodeSnippet.vue';

const themeVars = useThemeVars();

const snippetCode = `// Common git commands reference

// Initialize and configure
// git init
// git config --global user.name "{{name}}"
// git config --global user.email "{{email}}"

// Stage and commit
// git add .
// git commit -m "{{message}}"

// Branch and merge
// git checkout -b {{branch}}
// git merge {{branch}}

// Remote
// git remote add origin {{remote}}
// git push origin {{branch}}`;

const snippetVars = computed(() => ({
  name: 'Your Name',
  email: 'you@example.com',
  message: 'feat: add new feature',
  branch: 'feature/my-branch',
  remote: 'https://github.com/user/repo.git',
}));
</script>

<template>
  <div>
    <Memo />
  </div>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="bash" />
  </c-card>
</template>

<style lang="less" scoped>
::v-deep(pre) {
  margin: 0;
  padding: 15px 22px;
  background-color: v-bind('themeVars.cardColor');
  border-radius: 4px;
  overflow: auto;
}
</style>
