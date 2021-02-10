import Vue from 'vue'
import App from './app.vue'
import store from './store.js'
import router from './routes'

import Multiselect from 'vue-multiselect'
Vue.component('multiselect', Multiselect)

import './helpers/filters'
import './helpers/mixins'

document.addEventListener('DOMContentLoaded', () => {
  const wholeApp = new Vue({
    router,
    store,
    render: h => h(App)
  }).$mount()
  document.getElementById('workflow_designer').appendChild(wholeApp.$el)
})

