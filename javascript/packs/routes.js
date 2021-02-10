import Vue from 'vue';
import VueRouter from 'vue-router';
Vue.use(VueRouter);

import SelectionProcesses from './views/selection_processes';
import Designer from './views/designer';

const router = new VueRouter({
  mode: 'hash',
  routes: [
    { path: '/', redirect: '/selection_processes' },
    { path: '/selection_processes', component: SelectionProcesses, name: 'selection_processes_path' },
    { path: '/selection_processes/:id/designer', component: Designer, name: 'designer_path' }
  ]
});

export default router;