<template>
  <div>
    <h1>你好 Vue！</h1>
    <button @click="getName">获取姓名</button>
    <p>{{ result }}</p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const result = ref('')

const getName = async () => {
  axios.get('/api/myapp/getName')
  .then(res => {
    console.log(res.data);
    result.value = res.data
  });
  
}
</script>