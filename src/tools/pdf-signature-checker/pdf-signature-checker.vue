<script setup lang="ts">
import verifyPDF from 'pdf-signature-reader';
import type { SignatureInfo } from './pdf-signature-checker.types';
import { formatBytes } from '@/utils/convert';
import CodeSnippet from '@/components/CodeSnippet.vue';

const signatures = ref<SignatureInfo[]>([]);
const status = ref<'idle' | 'parsed' | 'error' | 'loading'>('idle');
const file = ref<File | null>(null);

async function onVerifyClicked(uploadedFile: File) {
  file.value = uploadedFile;
  const fileBuffer = await uploadedFile.arrayBuffer();

  status.value = 'loading';
  try {
    const { signatures: parsedSignatures } = verifyPDF(fileBuffer);
    signatures.value = parsedSignatures;
    status.value = 'parsed';
  }
  catch (e) {
    signatures.value = [];
    status.value = 'error';
  }
}

const snippetCode = `import verifyPDF from 'pdf-signature-reader';

// Read the PDF file as ArrayBuffer
const fileBuffer = await file.arrayBuffer();

const { signatures } = verifyPDF(fileBuffer);

// => Found {{signatureCount}} signature(s)
signatures.forEach((sig, i) => {
  console.log('Signature', i + 1, sig);
});`;

const snippetVars = computed(() => ({
  signatureCount: String(signatures.value.length),
}));
</script>

<template>
  <div style="flex: 0 0 100%">
    <div mx-auto max-w-600px>
      <c-file-upload
        title="Drag and drop a PDF file here, or click to select a file" accept=".pdf"
        @file-upload="onVerifyClicked"
      />

      <c-card v-if="file" mt-4 flex gap-2>
        <div font-bold>
          {{ file.name }}
        </div>

        <div>
          {{ formatBytes(file.size) }}
        </div>
      </c-card>

      <div v-if="status === 'error'">
        <c-alert mt-4>
          No signatures found in the provided file.
        </c-alert>
      </div>
    </div>
  </div>

  <div v-if="status === 'parsed' && signatures.length" style="flex: 0 0 100%" mt-5 flex flex-col gap-4>
    <div v-for="(signature, index) of signatures" :key="index">
      <div mb-2 font-bold>
        Signature {{ index + 1 }} certificates :
      </div>

      <pdf-signature-details :signature="signature" />
    </div>
  </div>

  <c-card title="Code snippet" mt-5>
    <CodeSnippet :code="snippetCode" :variables="snippetVars" language="javascript" />
  </c-card>
</template>
