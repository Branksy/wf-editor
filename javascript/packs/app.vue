<template lang='pug'>
  #wd-app
    notification
    transition(name='slide-fade')
      sidebar(ref='sidebar' v-show="$route.path != '/selection_processes' && edit_mode")
    router-view

</template>

<script>
import Notification from './components/notification'
import Sidebar from './components/sidebar'
import { mapState } from 'vuex'

export default {
  components: {
    Notification,
    Sidebar
  },
  computed: mapState(['edit_mode'])
}
</script>

<style lang='scss' scoped>
#wd-app {
  padding: 0px 0px;
  margin-top: -20px;
}
.slide-fade-enter-active, .slide-fade-leave-active {
  transition: all 0.3s ease-out;
}
.slide-fade-enter-from, .slide-fade-leave-to {
  transform: translateX(290px);
  opacity: 0;
}

::v-deep .multiselect {
  min-height: 32px;
  .multiselect__select {
    position: absolute;
    width: 20px;
    height: 32px;
    right: 1px;
    top: 1px;
    padding: 4px 8px;
    text-align: center;
    transition: transform .2s ease;
  }
  .multiselect--active {
    font-size: 13px;
  }
  .multiselect__tags {
    min-height: 32px;
    display: block;
    padding: 5px 40px 0 12px;
    border-radius: 5px;
    border: 1px solid #e8e8e8;
    background: #fff;
    font-size: 13px;
    height: inherit;
    border-radius: 0;
  }
  .multiselect__tag {
    border-radius: 2px;
    background: #009999;
  }
  .multiselect__select:before {
    position: relative;
    right: 2px;
    top: 65%;
    color: #999999d1;
    margin-top: 4px;
    border-color: #999c transparent transparent;
    border-style: solid;
    border-width: 4px 4px 0;
    content: "";
  }
  .multiselect__placeholder {
    color: #4b4e52;
    bottom: 0px;
    position: relative;
    margin-bottom: 0px;
  }
  .multiselect__option--highlight::after {
    height: 32px;
    padding: 0 12px;
  }
  .multiselect__option {
    height: 32px;
    min-height: 32px;
    padding: 8px 12px;
    font-size: 13px;
  }
  .multiselect__input {
    font-size: 13px;
    padding: 0;
    top: 1px;
    margin-bottom: 4px;
    position: relative;
  }
  .multiselect__content-wrapper {
    border-radius: 0;
  }
}

</style>
<style lang='scss'>
#wd-app {
  .flex {
    display: flex;
  }
  .center {
    align-items: center;
  }
  .vertical {
    flex-direction: column;
  }
  .start {
    justify-content: flex-start;
  }
  .end {
    justify-content: flex-end;
  }
  .reverse-vertical {
    flex-direction: column-reverse;
  }
  .space-between {
    justify-content: space-between;
    width:100%;
  }
  .hoverable:hover {
    background: whitesmoke;
    cursor: pointer;
    border-radius: 3px;
    transition: 0.3s background linear;
  }
  .router-link-active:hover {
    text-decoration: none;
  }
  .mt5 {margin-top: 5px;}
  .mb2 {margin-bottom: 2px;}
  .mb5 {margin-bottom: 5px;}
  .mb7 {margin-bottom: 7px;}
  .mb8 {margin-bottom: 8px;}
  .mb50 {margin-bottom: 50px;}
  .ml10 {margin-left: 10px;}
  .ml12 {margin-left: 12px;}
  .ml15 {margin-left: 15px;}
  .ml20 {margin-left: 20px;}
  .ml25 {margin-left: 25px;}
  .mr5 {margin-right: 5px;}
  .mr25 {margin-right: 25px;}
  .pl25 {padding-left: 25px;}
  .pl50 {padding-left: 50px;}

  .pointer {cursor: pointer;}
  .hint {
    color: #98999a;
    margin-top: 5px;
  }
}

</style>
