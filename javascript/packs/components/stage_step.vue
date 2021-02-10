<template lang='pug'>
.stage-step
  accordion
    template(v-slot:header='{show: show}')
      .flex.center.vertical
        .flex.center.pl25
          .stage-header(style='justify-content:center' @click='toggleArrow')
            .count {{ stateCount() }}
            tag-icon(icon='Flag' accent='white' style='position:absolute;left:15px; z-index:1000' v-if='stage_index == 0')
            tag-button(:text='stage.title' accent='keppel'  size='large' button-style='{"height":"38px", "padding": "0px 60px", "border-radius": "6px", "fontSize":"14px"}')
            .header-icon.move-left(:class="{rotate: show}")
              tag-icon(icon='ArrowRight' icon-style='{"fill": "white"}' size='14')
          .delete(:style='edit_mode ? {"visibility":"visible"} : {"visibility":"hidden"}')
            tag-icon(icon='Delete' size='20px' icon-style='{"fill":"#919dbc"}' @click="$emit('removeStage', stage_index)")
            tag-icon(icon='Edit' size='20px' icon-style='{"fill":"#919dbc"}' @click.stop='$root.$children[0].$refs.sidebar.editItem(stage, "stage")')

    .stage-content(:class="{'dashed': stage.workflow_states.length == 0}")
      draggable(v-model='stage.workflow_states' group='states' ghost-class="state-ghost" class="state-drag-area", :animation='200' @add='$forceUpdate()' @remove='$forceUpdate()' :disabled='!edit_mode')
        .state(v-for='(state, index) in stage.workflow_states' :key="'state_'+ state.title + index")
          .flex.reverse-vertical
            state-transitions(:state='state'
                              :last_stage='last_stage'
                              :last_state='index == Object.keys(stage.workflow_states).length - 1'
                              :key="'state_'+ state.title + index"
                              :state_index='index'
                              @removeState='stage.workflow_states.splice($event, 1)')

  transition(name='stage-arrow')
    arrow.rel(v-show='!last_stage && show_arrow')

</template>


<script>
import Draggable from 'vuedraggable'
import StateTransitions from './state_transitions'
import Accordion from './accordion'
import Arrow from './arrow'
import { mapState } from 'vuex'

export default {
  props: ['stage', 'last_stage', 'stage_index'],
  components: {
    StateTransitions,
    Accordion,
    Arrow,
    Draggable
  },
  data () {
    return {
      show_arrow: true
    }
  },
  methods: {
    toggleArrow() {
      this.show_arrow = !this.show_arrow
    },
    stateCount() {
      return this.stage.workflow_states.length
    }
  },
  computed: {
    ...mapState(['edit_mode', 'selection_process_tree'])
  }
}
</script>


<style lang='scss' scoped>
.stage-step {
  width: 100%;
  margin-top: 5px;

  .stage-header {
    display: flex;
    align-items: center;
    position: relative;
    right: -13px;
  }
  .stage-header + .delete {
    position: relative;
    left: 25px;
  }
}
.stage-content {
  padding-top: 20px;
  display: flex;
  flex-direction: column;
  min-height: 100px;
}
.count {
  border-radius: 50%;
  height: 20px;
  width: 20px;
  background: white;
  color: #68b590;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: -30px;
  z-index:1000;
  visibility: hidden;
}

.move-left {
  margin-left: -25px;
  z-index:1000;
}

.rel {
  position: relative;
  top:0;
  transition-delay: 150ms;
  transition: 150ms ease-out;
}

.stage-arrow-enter-active {
  transition: opacity 0.5s;
}
.stage-arrow-leave-active {
  transition: opacity 0s;
}
.stage-arrow-enter, .stage-arrow-leave-to {
  opacity: 0;
}
.stage-arrow-leave-to {
  margin-top: -45px;
}

</style>

<style>
.stage-drag-area, .state-drag-area {
  min-height: 50px;
}
.transition-drag-area {
  min-height: 50px;
  width: 250px;
}

.dashed {
  outline: 2px dashed #c9d8dd8a;
  width: 75%;
  margin: 10px auto;
}
</style>