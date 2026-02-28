<script setup lang="ts">
import { useBase64 } from '@vueuse/core';
import type { Ref } from 'vue';
import { getExtensionFromMimeType, getMimeTypeFromBase64, previewImageFromBase64, useDownloadFileFromBase64Refs } from '@/composable/downloadBase64';
import { useValidation } from '@/composable/validation';
import { isValidBase64 } from '@/utils/base64';
import CodeSnippet from '@/components/CodeSnippet.vue';

const fileName = ref('file');
const fileExtension = ref('');
const base64Input = ref('');
const { download } = useDownloadFileFromBase64Refs(
  {
    source: base64Input,
    filename: fileName,
    extension: fileExtension,
  });
const base64InputValidation = useValidation({
  source: base64Input,
  rules: [
    {
      message: 'Invalid base 64 string',
      validator: value => isValidBase64(value.trim()),
    },
  ],
});

watch(
  base64Input,
  (newValue, _) => {
    const { mimeType } = getMimeTypeFromBase64({ base64String: newValue });
    if (mimeType) {
      fileExtension.value = getExtensionFromMimeType(mimeType) || fileExtension.value;
    }
  },
);

function previewImage() {
  if (!base64InputValidation.isValid) {
    return;
  }
  try {
    const image = previewImageFromBase64(base64Input.value);
    image.style.maxWidth = '100%';
    image.style.maxHeight = '400px';
    const previewContainer = document.getElementById('previewContainer');
    if (previewContainer) {
      previewContainer.innerHTML = '';
      previewContainer.appendChild(image);
    }
  }
  catch (_) {
    //
  }
}

function downloadFile() {
  if (!base64InputValidation.isValid) {
    return;
  }

  try {
    download();
  }
  catch (_) {
    //
  }
}

const fileInput = ref() as Ref<File>;
const { base64: fileBase64 } = useBase64(fileInput);

async function onUpload(file: File) {
  if (file) {
    fileInput.value = file;
  }
}

const snippetCode = `// File to Base64 using FileReader API
function fileToBase64(file) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = (e) => resolve(e.target.result);
    reader.readAsDataURL(file);
  });
}

// Base64 back to a downloadable file blob
function base64ToFile(base64, filename, mimeType) {
  const byteString = atob(base64.split(',')[1] ?? base64);
  const ab = new Uint8Array(byteString.length);
  byteString.split('').forEach((c, i) => (ab[i] = c.charCodeAt(0)));
  return new File([ab], filename, { type: mimeType });
}

// Current file: '{{filename}}'
const result = await fileToBase64(file);
// => '{{output}}'`;

const snippetVars = computed(() => ({
  filename: fileInput.value?.name ?? 'example.png',
  output: fileBase64.value?.slice(0, 40) ?? 'data:image/png;base64,iVBOR...',
}));
</script>

<template>
  <c-card title="Base64 to file">
    <n-grid cols="3" x-gap="12">
      <n-gi span="2">
        <c-input-text v-model:value="fileName" label="File Name" placeholder="Download filename" mb-2 />
      </n-gi>
      <n-gi>
        <c-input-text v-model:value="fileExtension" label="Extension" placeholder="Extension" mb-2 />
      </n-gi>
    </n-grid>
    <c-input-text
      v-model:value="base64Input" multiline placeholder="Put your base64 file string here..." rows="5"
      :validation="base64InputValidation" mb-2
    />

    <div flex justify-center py-2>
      <div id="previewContainer" />
    </div>

    <div flex justify-center gap-3>
      <c-button :disabled="base64Input === '' || !base64InputValidation.isValid" @click="previewImage()">
        Preview image
      </c-button>
      <c-button :disabled="base64Input === '' || !base64InputValidation.isValid" @click="downloadFile()">
        Download file
      </c-button>
    </div>
  </c-card>

  <c-card title="File to base64">
    <c-file-upload title="Drag and drop a file here, or click to select a file" @file-upload="onUpload" />
    <CodeSnippet :value="fileBase64" copy-message="Base64 string copied to the clipboard" mt-2 />
  </c-card>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>

<style lang="less" scoped>
::v-deep(.n-upload-trigger) {
  width: 100%;
}
</style>
