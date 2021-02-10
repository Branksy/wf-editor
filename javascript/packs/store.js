import Vue from 'vue'
import Vuex from 'vuex'
import axios from './axios.js'
import VueAxios from 'vue-axios'
Vue.use(Vuex)
Vue.use(VueAxios, axios)

export default new Vuex.Store({
  state: {
    selection_process_tree: [],
    selection_process: {},
    selection_processes: [],
    stages: [],
    states: [],
    actions: [],
    progressions: [],
    errors: [],
    status: '',
    edit_mode: false
  },
  mutations: {
    TOGGLE_EDIT_MODE (state) {
      state.edit_mode = !state.edit_mode
      return state
    },
    RESET_EDIT_MODE (state) {
      state.edit_mode = false
      return state
    },
    SET_SIDEBAR (state, data) {
      state.stages = data.stages
      state.states = data.states
      state.actions = data.actions
      state.progressions = data.progressions
      return state
    },
    SET_TREE (state, data) {
      state.selection_process_tree = data
      return state
    },
    SET_TREE_WITH_STAGE (state, data) {
      state.selection_process_tree.forEach(stage => {
        if(stage.id == data.id) {
          stage.name = data.name
          stage.title = data.title
        }
      })
      return state
    },
    SET_TREE_WITH_STATE (state, data) {
      state.selection_process_tree.forEach(stage => {
        stage.workflow_states.forEach(state => {
          if(state.id == data.id) {
            state.name = data.name
            state.title = data.title
          }
        })
      })
      return state
    },
    SET_TREE_WITH_TRANSITION (state, data) {
      state.selection_process_tree.forEach(stage => {
        stage.workflow_states.forEach(state => {
          state.actions.forEach((action, index) => {
            if(action.id == data.id) {
              action.name = data.name
              action.title = data.title
              if(Number(data.destination_type) != 0) {
                state.actions.splice(index, 1)
                state.progressions.push(data)
              }
            }
          })
          state.progressions.forEach((prog, index) => {
            if(prog.id == data.id) {
              prog.name = data.name
              prog.title = data.title
              if(Number(data.destination_type) == 0) {
                state.progressions.splice(index, 1)
                state.actions.push(data)
              }
            }
          })
        })
      })
      return state
    },
    ONE_SELECTION_PROCESS (state, data) {
      state.selection_process = data
      return state
    },
    MANY_SELECTION_PROCESSES (state, data) {
      state.selection_processes = data
      return state
    },
    MANY_STAGES (state, data) {
      state.stages = data
      return state
    },
    MANY_STATES (state, data) {
      state.states = data
      return state
    },
    MANY_TRANSITIONS (state, data) {
      state.actions = data.actions
      state.progressions = data.progressions
      return state
    },
    ERRORS (state, data) {
      state.errors = data
      return state
    },
    STATUS (state, data) {
      state.status = data
      return state
    },
    CLEAR_ERRORS (state) {
      state.errors = ''
      return state
    },
    CLEAR_STATUS (state) {
      state.status = ''
      return state
    }
  },
  actions: {
    // SIDEBAR
    sidebar(context) {
      axios.get('/sidebar')
      .then(response => {
        context.commit('SET_SIDEBAR', response.data)
      });
    },
    // WORKFLOW TREE
    async update_tree(context, params) {
      await axios.put(`/selection_processes/${params.id}/update_tree`, {workflow_tree: params.selection_process_tree})
      .then(response => {
        context.commit('STATUS', response.status)
      })
    },
    // SELECTION PROCESS
    index(context) {
      axios.get('/selection_processes')
      .then(response => {
        context.commit('MANY_SELECTION_PROCESSES', response.data)
      });
    },
    async edit(context, params_id) {
      await axios.get(`/selection_processes/${params_id}/edit`)
      .then(response => {
        context.commit('ONE_SELECTION_PROCESS', response.data.selection_process)
        context.commit('SET_TREE', response.data.selection_process_tree)
      });
    },
    create(context, params) {
      axios.post('/selection_processes', params)
      .then(response => {
        context.commit('MANY_SELECTION_PROCESSES', response.data);
        context.commit('STATUS', response.status)
      })
      .catch(error => {
        context.commit('ERRORS', error.response.data);
      });
    },
    update(context, params) {
      axios.put(`/selection_processes/${params.id}`, {selection_process: params})
      .then(response => {
        context.commit('ONE_SELECTION_PROCESS', response.data);
        context.commit('STATUS', response.status)
      })
      .catch(error => {
        context.commit('ERRORS', error.response.data);
      });
    },
    //STAGE
    create_stage(context, params) {
      axios.post('/workflow_stages', params)
      .then(response => {
        context.commit('MANY_STAGES', response.data);
        context.commit('STATUS', response.status);
      })
      .catch(error => {
        context.commit('ERRORS', error.response.data);
      });
    },
    update_stage(context, params) {
      axios.put(`/workflow_stages/${params.id}`, params)
      .then(response => {
          context.commit('STATUS', response.status)
          context.commit('SET_TREE_WITH_STAGE', params)
          context.commit('MANY_STAGES', response.data.stages);
      })
      .catch(error => {
          context.commit('ERRORS', error.response.data);
      });
    },
    //STATE
    create_state(context, params) {
      axios.post('/workflow_states', params)
      .then(response => {
        context.commit('MANY_STATES', response.data);
        context.commit('STATUS', response.status);
      })
      .catch(error => {
        context.commit('ERRORS', error.response.data);
      });
    },
    update_state(context, params) {
      axios.put(`/workflow_states/${params.id}`, params)
      .then(response => {
          context.commit('STATUS', response.status)
          context.commit('SET_TREE_WITH_STATE', params)
          context.commit('MANY_STATES', response.data.states);
      })
      .catch(error => {
          context.commit('ERRORS', error.response.data);
      });
    },
    //TRANSITION
    create_transition(context, params) {
      axios.post('/workflow_transitions', params)
      .then(response => {
        context.commit('MANY_TRANSITIONS', response.data);
        context.commit('STATUS', response.status);
      })
      .catch(error => {
        context.commit('ERRORS', error.response.data);
      });
    },
    update_transition(context, params) {
      axios.put(`/workflow_transitions/${params.id}`, params)
      .then(response => {
        context.commit('MANY_TRANSITIONS', response.data);
        context.commit('STATUS', response.status)
        context.commit('SET_TREE_WITH_TRANSITION', params);
      })
      .catch(error => {
          context.commit('ERRORS', error.response.data);
      });
    },
  }
})
