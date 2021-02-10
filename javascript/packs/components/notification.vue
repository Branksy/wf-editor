<template lang='pug'>
div
  tag-toast.errors(position='top-right')
    tag-alert.errors(
      ref='status_errors'
      type='warning'
      alert-type='toast'
      visible='false'
      show-duration='10000'
      closeable)
  tag-toast.info(position='top-right')
    tag-alert.info(
      ref='status_success'
      type='information'
      alert-type='toast'
      visible='false'
      show-duration='3500'
      text='Saved Sucessfully')

</template>


<script>
import { mapState } from 'vuex'
export default {
  computed: {
    ...mapState(['errors', 'status']),
    errorMessageText() {
      var n = Object.keys(this.errors).length
      var message = ''
      for(var i = 0; i < n; i++) {
        message += Object.keys(this.errors)[i].toUpperCase() +': '+ Object.values(this.errors)[i] +'<br />'
      }
      return message
    }
  },
  watch: {
    errors() {
      if(this.errors) {
        document.querySelector('tag-alert.errors').shadowRoot.querySelector('.tag-alert__text').innerHTML = this.errorMessageText
        this.$refs.status_errors.show()
        setTimeout( () => {
          this.$store.commit('CLEAR_ERRORS')
        }, 10000)
      }
    },
    status() {
      this.$refs.status_success.show()
      setTimeout( () => {
        this.$store.commit('CLEAR_STATUS')
      }, 3000)
    }
  }
}
</script>

<style lang='scss' scoped>
.errors, .info {
  position:relative;
  right: calc(50vw - 135px);
  top: 0vh;
  width: 280px;
}
</style>
<style lang="scss">
.edit_toast {
  position:relative;
  right:calc(50vw - 150px);
  top:0vh;
  width:320px;
}
</style>