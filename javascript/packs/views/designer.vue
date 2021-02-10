<template lang='pug'>
div
  .designer(:class="{'edit_mode': edit_mode}" v-if='loaded')
    .top-heading.flex.center.space-between
      .flex.center
        router-link(to='/selection_processes')
          .back-button.flex.center
            tag-icon(icon='ChevronLeft')
            | {{ backToName() }}
        .pointer
          tag-icon.ml15(icon='Edit' icon-style='{"fill":"#919dbc"}' @click="editItem(selection_process, 'selection-process')")

      .edit-mode
        .flex
          tag-button(icon='Edit' text='Edit Workflow' button-icon-style='{"fill":"#919dbc"}' @click='toggleEditMode' v-if='!edit_mode')
          .flex.center(v-else)
            tag-button.mr5(icon='Save' text='Save Workflow' icon-accent="title" @click='saveWorkflowTree()')
            tag-button(icon='Cross' icon-accent="coral" @click='toggleEditMode')
          tag-progress-indeterminate(accent='primary' style='position:absolute;right:830px' v-if='saving_in_progress')

    .workflow_tree
      .hint(v-if='edit_mode && selection_process_tree.length == 0') Drag & Drop initial workflow Stage
      .hint(v-if='!edit_mode && selection_process_tree.length == 0') This Selection Process workflow is currently empty.
      .flex.vertical(:class="{'dashed': edit_mode && selection_process_tree.length == 0}")
        draggable(:list='selection_process_tree' ghost-class="stage-ghost" class='stage-drag-area' group="stages", :animation='200' @add='$forceUpdate()' :disabled='!edit_mode')
          template(v-for='(stage, index) in selection_process_tree')
            stage-step( :stage='stage'
                        :last_stage='index == Object.keys(selection_process_tree).length - 1'
                        :key="'stage_'+ stage.title + index"
                        :stage_index='index'
                        @removeStage='selection_process_tree.splice($event, 1)')

    tag-modal(ref='editable' width='small' border-accent='coral', :heading="'Edit '+ toTitleCase(editable_type.split('-').join(' '))" header-option-4='' header-option-4-text='' header-option-4-accent=''  header-option-4-rounded-background-accent='')
      edit-selection-process(ref='edit', :is="'edit-'+ editable_type")

    tag-toast.edit_toast(position='top-right')
      tag-alert.edit_toast(
        ref='alert'
        type='information'
        alert-type='toast'
        visible='false'
        text=''
        show-duration='3500'
        closeable)
  .size-alert The Workflow Designer can only be used on devices with screen widths greater than 900px.

</template>

<script>
import ButtonStuff from '../components/button'
import Draggable from 'vuedraggable'
import StageStep from '../components/stage_step'
import Accordion from '../components/accordion'
import VuePill from '../components/vtag_pill'
import EditSelectionProcess from '../views/selection_processes/edit'
import { mapState } from 'vuex'

export default {
  components: {
    ButtonStuff,
    StageStep,
    Accordion,
    Draggable,
    VuePill,
    EditSelectionProcess
  },
  data() {
    return {
      edit: false,
      saving_in_progress: false,
      editable_type: 'selection-process',
      editable_item: {},
      newable_type: '',
      loaded: false
    }
  },
  computed: {
    ...mapState([
      'selection_process_tree', 'selection_process', 'stages', 'states', 'actions', 'progressions', 'errors', 'status', 'edit_mode'
    ]),
    stageIds() {
      return this.selection_process_tree.map(_ => _.id)
    }
  },
  methods: {
    backToName() {
      return this.selection_process.name +'('+ this.selection_process.abbreviation +')'
    },
    saveWorkflowTree() {
      this.saving_in_progress = true;
      var params = { id: this.$route.params.id, selection_process_tree: this.selection_process_tree }
      this.$store.dispatch('update_tree', params).then(() => {
        this.saving_in_progress = false;
        this.$store.dispatch('sidebar')
        this.$store.dispatch('edit', this.$route.params.id)
      });
    },
    editItem(item, item_type) {
      this.editable_item = item;
      this.editable_type = item_type;
      this.$refs.editable.show();
      this.$refs.edit.getData();
    },
    toggleEditMode() {
      this.$store.commit('TOGGLE_EDIT_MODE')
    }
  },
  created() {
    this.$store.dispatch('edit', this.$route.params.id)
    .then(response => {
      this.loaded = true
      this.$forceUpdate()
    })
  },
  watch: {
    edit_mode() {
      if(this.edit_mode == true) {
        this.$refs.alert.type = 'warning';
        this.$refs.alert.text = 'You are now in EDIT Mode';
        this.$refs.alert.show()
      } else {
        this.$store.dispatch('edit', this.$route.params.id)
      }
    }
  }
}
</script>

<style lang='scss' scoped>
.designer {
  width: 100%;
  padding-right: 20px;
  transition: width 150ms ease-out;
  @media screen and (max-width: 900px) { display: none; }
  &.edit_mode {
    @media screen and (min-width: 1400px) {
      width: calc(100% - 290px);
    }
  }
}
.size-alert {
  display: none;
  margin-top: 20px;
  @media screen and (max-width: 900px) { display: block; }
}
.top-heading {
  margin-top: 25px;
  .back-button {
    text-decoration: none !important;
    color:#373737;
    font-size: 24px;
  }
}

.workflow_tree {
  width: 100%;
  margin-top: 100px;

  .hint {
    margin-top: 10px;
    font-size: 16px;
    text-align: center;
    color: rgb(128, 128, 128);
  }
}

</style>

<style lang='scss'>
.labels {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  font-size: 12px;
  color: rgb(128, 128, 128);
}
.labels .flex.center:first-child, .labels .txt {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.stage-ghost {
  background: transparent;
  color: transparent;
  width: fit-content;
  height: fit-content;
  min-width: 200px;
  min-height: 36px;
  margin: 0 auto;
  border-radius: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
  border: 2px solid #67b590;
  padding: 5px;
  tag-icon {
    margin-left: 15px;
  }
  tag-icon + div, .arrow, tag-badge, .hover-only {
    display: none;
  }
  .labels {
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
.state-ghost {
  background:white;
  color: transparent;
  width: fit-content;
  height: fit-content;
  min-width: 180px;
  min-height: 36px;
  margin: 0 auto;
  border-radius: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  tag-icon.state {
    margin-left: 10px;
  }
  tag-icon.state + div, tag-badge, .hover-only {
    display: none;
  }
  .labels {
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
.transition-ghost {
  background: white;
  color: transparent;
  min-width: 250px;
  min-height: 30px;
  margin-bottom: 5px;
  border-radius: 5px;
  tag-icon {
    margin-left: 12px;
    margin-top: 5px;
  }
  tag-icon + div {
    display: none;
  }
}

.item.stage.sortable-chosen {
  margin-top: 10px;
  margin-bottom: 20px;
}

.item.state.sortable-chosen {
  margin-top: 5px;
  margin-bottom: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0);
}
.item.transition.sortable-chosen {
  margin-top: 5px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.22), 0 1px 2px rgba(0, 0, 0, 0);
}

.litetext {
  color: #c9d8dd;
}

.delete { z-index: 1000; }
.delete > tag-icon {
  visibility: hidden;
  margin-left: 5px;
  cursor: pointer;
}
.delete:hover > tag-icon {
  visibility: visible;
}

.hover-only {
  position: relative;
  right: -15px;
  visibility: hidden;
  cursor: pointer;
}
.item:hover .hover-only {
  visibility: visible;
}
</style>
<style src="vue-multiselect/dist/vue-multiselect.min.css"></style>