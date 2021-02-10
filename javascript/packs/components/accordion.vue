<template lang='pug'>
.designer-accordion
  div(@click="trigger")
    slot(name="header" :show='show')

  transition(name="accordion"
              @before-enter="beforeEnter"
              @enter="enter"
              @after-enter='afterEnter'
              @leave="leave"
              @after-leave='afterLeave')
    .body(v-show="show")
      .body-inner
        slot

</template>


<script>
export default {
  props: {
    open: Boolean,
    default: false
  },
  data() {
    return {
      show: this.open
    }
  },
  methods: {
    trigger(el) {
      this.show = !this.show
    },
    beforeEnter(el) {
      el.style.height = 0;
    },
    enter(el) {
      el.style.height = el.scrollHeight + 'px';
    },
    afterEnter(el) {
      el.style.height = 'auto';
    },
    leave(el) {
      el.style.height = el.scrollHeight + 'px';
    },
    afterLeave(el) {
      el.style.height = 0;
    },
  }
}
</script>

<style lang='scss'>

.designer-accordion .header-icon {
  transform: rotate(0deg);
  transition-duration: 0.3s;
}

.designer-accordion .body {
  transition: 150ms ease-out;
}

.designer-accordion .body-inner {
  overflow-wrap: break-word;
}

.designer-accordion .header-icon.rotate {
  transform: rotate(90deg);
  transition-duration: 0.3s;
}

.accordion-leave-to {
  height: 0 !important;
}
</style>