<template lang="pug">
.arrow
  .top
  .line
  .pointer
    tag-icon(icon='ArrowDown' icon-style='{"fill": "#c9d8dc"}' size='16')

</template>

<script>
export default {

}
</script>

<style lang='scss' scoped>
.arrow {
  position: absolute;
  top: 40px;
  margin-top: 5px;
  display:flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height:100%;

  .top {
  min-height: 6px;
  min-width: 6px;
  border-radius: 50%;
  background: #c9d8dc;
  }
  .line {
    min-height: 30px;
    display: flex;
    height: 100%;
    width: 2px;
    background: #c9d8dc;
  }
  .pointer {
    margin-top: -7px;
  }
}
</style>