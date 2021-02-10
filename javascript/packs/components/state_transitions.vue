<template lang="pug">
.row.state-content
  .col.col-sm-4
    .transitions.flex.vertical
      .transition-heading(v-if='state.actions.length')
        tag-icon(icon='Briefcase' size='18' icon-style='{"fill":"#919dbc"}')
        span Actions
      draggable(class="transition-drag-area" v-model='state.actions' group="actions" ghost-class="transition-ghost", :animation='200' @change='syncStates(state)' @add="$forceUpdate()" @remove="syncStates(state)" :disabled='!edit_mode')
        .mb7.flex.center(v-for='(action, index) in state.actions' :key="'action_'+ action.title + index")
          tag-button(accent='white'
                      :text='action.title'
                      size='default'
                      button-style='{"fontSize":"12px", "border-radius":"4px", "cursor":"grab", "width": "250px", "color":"#808080", "box-shadow":"0px 3px 15px rgba(0,0,0,0.08)"}'
                      button-text-style='{"width":"225px", "display":"block", "overflow":"hidden", "text-overflow":"ellipsis", "white-space":"nowrap", "text-align":"left"}'
                      button-text-container-style='{"padding":"4px 6px", "position":"absolute", "left":"10px"}')
          .flex.delete(v-if='edit_mode')
            tag-icon(icon-style='{"fill":"#919dbc"}' icon='Delete' size='16px' @click='state.actions.splice(index, 1);syncStates(state)')
            tag-icon(icon-style='{"fill":"#919dbc"}' icon='Edit' size='16px' @click='$root.$children[0].$refs.sidebar.editItem(action, "action")')

  .col.col-sm-4
    .state.flex.center.vertical
      .flex.center.pl50
        tag-button.mb8(size='large' accent='white', :text='state.title' button-style='{"border-radius":"5px", "height": "38px", "width": "180px", "color": "#D5763F", "box-shadow":"0px 3px 15px rgba(0,0,0,0.1)"}'
          button-text-style='{"width":"160px", "display":"block", "overflow":"hidden", "text-overflow":"ellipsis", "white-space":"nowrap"}')

        .flex.delete(:style='edit_mode ? {"visibility":"visible"} : {"visibility":"hidden"}')
          tag-icon(icon='Delete' size='18px' icon-style='{"fill":"#919dbc", "marginBottom":"3px"}' @click="$emit('removeState', state_index)")
          tag-icon(icon='Edit' size='18px' icon-style='{"fill":"#919dbc", "marginBottom":"3px"}' @click='$root.$children[0].$refs.sidebar.editItem(state, "state")')

      arrow(v-if='!(last_stage && last_state)')

  .col.col-sm-4
    .transitions.flex.vertical
      .transition-heading(v-if='state.progressions.length')
        tag-icon(icon='Merge' size='18' icon-style='{"fill":"#919dbc"}')
        span Transitions
      draggable(class="transition-drag-area" v-model='state.progressions' group="progressions" ghost-class="transition-ghost", :animation='200' @change='syncStates(state)' @add="$forceUpdate()" @remove="$forceUpdate()" :disabled='!edit_mode')
        .mb7.flex.center(v-for='(progression, index) in state.progressions' :key="'progression_'+ progression.title + index")
          tag-button(accent='white'
                        :text='progression.title'
                        size='default'
                        button-style='{"fontSize":"12px", "border-radius":"4px", "cursor":"grab", "white-space": "nowrap", "overflow":"hidden", "text-overflow":"ellipsis", "width": "250px", "color":"#808080", "box-shadow":"0px 3px 15px rgba(0,0,0,0.08)"}'
                        button-text-style='{"width":"225px", "display":"block", "overflow":"hidden", "text-overflow":"ellipsis", "white-space":"nowrap", "text-align":"left"}'
                        button-text-container-style='{"position":"absolute", "left":"10px"}')
          .flex.delete(v-if='edit_mode')
            tag-icon(icon='Delete' size='16px' icon-style='{"fill":"#919dbc"}' @click='state.progressions.splice(index, 1);syncStates(state)')
            tag-icon(icon='Edit' size='16px' icon-style='{"fill":"#919dbc"}' @click='$root.$children[0].$refs.sidebar.editItem(progression, "transition")')

</template>

<script>
import Draggable from 'vuedraggable'
import Arrow from './arrow'
import axios from 'axios'
import { mapState } from 'vuex'

export default {
  props: ['state', 'last_state', 'last_stage', 'state_index'],
  components: {
    Arrow,
    Draggable
  },
  computed: {
    ...mapState(['edit_mode', 'selection_process_tree'])
  },
  methods: {
    syncStates(changed_state) {
      this.selection_process_tree.forEach(stage => {
        var state_indexes = []
        stage.workflow_states.forEach( (state, state_index) => {
          if(state.id == changed_state.id) {
            state_indexes.push(state_index)
          }
        })
        state_indexes.forEach(index => {
          stage.workflow_states.splice(index, 1, changed_state)
        })
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.row {
  display: flex;
  flex-wrap: wrap;
  margin-top: -5px;
}
.col-sm-4 {
  min-width: 250px;
  display: flex;
  justify-content: center;
}
.col-sm-4:first-child, .col-sm-4:last-child {
  position:relative;
}
.state-content {
  margin-bottom: 50px;
  padding: 0 30px;
}

.transition-heading {
  position: absolute;
  align-self:flex-start;
  display: flex;
  align-items: center;
  top: -25px;
  z-index: 1000;
  color: #919dbc;

  span {
    margin-left: 8px;
  }
}

//safari bootstrap grid fix
.row:before, .row:after {
  display: flex !important;
}
</style>