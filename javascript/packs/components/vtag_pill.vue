<template lang="pug">
  .pill
    slot
</template>

<script>
export default {

}
</script>

<style lang="scss" scoped>
.pill {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 2px;
  width: fit-content;
  white-space: nowrap;
  // background:#e6f4f4;
  // color:#53b8b4;
  background: #E2ECEF;
  color: #4B4E52;
  margin-right: 10px;
}
</style>