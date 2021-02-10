<template lang="pug">
.right-sidebar(ref="draggableContainer" id="draggable-container")
  tag-button.movable(icon='Move' size='small' button-style='{"background":"white", "cursor":"move"}' button-icon-style='{"fill":"#919dbc", "height": "14px"}' @mousedown="dragMouseDown")
  br
  .search
    tag-searchbox(clear-button='true' placeholder='Stage, state or transition name' @search='search_term = $event.detail.criteria')
  accordion(open)
    template(v-slot:header='{show: show}')
      .item-head
        h6 Stages
        .header-icon(:class="{rotate: show}")
          tag-icon(icon='ChevronRight' size='small' icon-style='{"height": "16px"}')
    tag-button(accent='' icon='Plus' size='small' button-icon-style='{"fill":"lightgrey"}' button-style='{"height": "26px", "width": "266px", "marginLeft":"19px"}' @click="newItem($event, 'stage')")
    draggable.item-list(:list='filteredStages' :group="{ name: 'stages', pull: 'clone', put: false }" :clone="clone" :move='allowMove')
      .item.stage(v-for='stage in filteredStages' :key='stage.id')
        .labels
          .flex.center
            tag-icon(icon='Flag' accent='coral' style='margin-right: 10px')
            .txt {{ stage.name}}
          .flex.center
            vue-pill(v-if='stageIds.includes(stage.id)' style='margin-right:-4px; margin-left:10px') In use
            .hover-only
              tag-icon(icon='Edit' size='small' icon-style='{"height": "16px", "fill":"#919dbc"}' @click="editItem(stage, 'stage')")
  accordion(open)
    template(v-slot:header='{show: show}')
      .item-head(slot='header')
        h6 States
        .header-icon(:class="{rotate: show}")
          tag-icon(icon='ChevronRight' size='small' icon-style='{"height": "16px"}')
    tag-button(accent='' icon='Plus' size='small' button-icon-style='{"fill":"lightgrey"}' button-style='{"height": "26px", "width": "266px", "marginLeft":"19px"}' @click="newItem($event, 'state')")
    draggable.item-list(:list='filteredStates' :group="{ name: 'states', pull: 'clone', put: false }" :clone="clone")
      .item.state(v-for='state in filteredStates')
        .labels
          .flex.center
            tag-icon.state(icon='Triangle' accent='keppel' size='20' style='margin-right: 10px')
            .txt {{ state.name}}
          .hover-only
            tag-icon(icon='Edit' size='small' icon-style='{"height": "16px", "fill":"#919dbc"}' @click="editItem(state, 'state')")
  accordion(open)
    template(v-slot:header='{show: show}')
      .item-head(slot='header')
        h6 Actions
        .header-icon(:class="{rotate: show}")
          tag-icon(icon='ChevronRight' size='small' icon-style='{"height": "16px"}')
    tag-button(accent='' icon='Plus' size='small' button-icon-style='{"fill":"lightgrey"}' button-style='{"height": "26px", "width": "266px", "marginLeft":"19px"}' @click="newItem($event, 'action')")
    draggable.item-list(v-model='filteredActions' :group="{name: 'actions', pull: 'clone', put: false }" :clone="clone")
      .item.transition(v-for='action in filteredActions')
        .labels
          .flex.center
            tag-icon(icon='Briefcase' size='20' icon-style='{"fill":"#919dbc"}' style='margin-right: 10px')
            .txt {{ action.name }}
          .hover-only
            tag-icon(icon='Edit' size='small' icon-style='{"height": "16px", "fill":"#919dbc"}' @click="editItem(action, 'action')")
  accordion(open)
    template(v-slot:header='{show: show}')
      .item-head(slot='header')
        h6 Transitions
        .header-icon(:class="{rotate: show}")
          tag-icon(icon='ChevronRight' size='small' icon-style='{"height": "16px"}')
    tag-button(accent='' icon='Plus' size='small' button-icon-style='{"fill":"lightgrey"}' button-style='{"height": "26px", "width": "266px", "marginLeft":"19px"}' @click="newItem($event, 'transition')")
    draggable.item-list(v-model='filteredProgressions' :group="{name: 'progressions', pull: 'clone', put: false }" :clone="clone")
      .item.transition(v-for='progression in filteredProgressions')
        .labels
          .flex.center
            tag-icon(icon='Merge' size='20' icon-style='{"fill":"#919dbc"}' style='margin-right: 10px')
            .txt {{ progression.name }}
          .hover-only
            tag-icon(icon='Edit' size='small' icon-style='{"height": "16px", "fill":"#919dbc"}' @click="editItem(progression, 'transition')")

  tag-modal(ref='newable' width='small' border-accent='coral', :heading="'New '+ toTitleCase(newable_type.split('-').join(' '))" header-option-4='' header-option-4-text='' header-option-4-accent=''  header-option-4-rounded-background-accent='' content-style='{"overflow": "scroll", "max-height":"80vh"}')
    component(:is="'new-'+ component_type" v-if='newable_type', :key='new_modal_count' :prog_or_act='newable_type')
  tag-modal(ref='editable' width='small' border-accent='coral', :heading="'Edit '+ toTitleCase(editable_type.split('-').join(' '))" header-option-4='' header-option-4-text='' header-option-4-accent=''  header-option-4-rounded-background-accent='' content-style='{"overflow": "scroll", "max-height":"80vh"}')
    component(:is="'edit-'+ component_type" :item='editable_item' v-if='editable_item && editable_type' :key='edit_modal_count' :prog_or_act='editable_type')

</template>

<script>
import Draggable from 'vuedraggable'
import StageStep from './stage_step'
import Accordion from './accordion'
import VuePill from './vtag_pill'
import EditSelectionProcess from '../views/selection_processes/edit'
import NewStage from '../views/stages/new'
import EditStage from '../views/stages/edit'
import NewState from '../views/states/new'
import EditState from '../views/states/edit'
import NewTransition from '../views/transitions/new'
import EditTransition from '../views/transitions/edit'
import { mapState } from 'vuex'

export default {
  components: {
    StageStep,
    Accordion,
    Draggable,
    VuePill,
    EditSelectionProcess,
    NewStage,
    EditStage,
    NewState,
    EditState,
    NewTransition,
    EditTransition
  },
  data() {
    return {
      search_term: '',
      editable_type: '',
      editable_item: {},
      newable_type: '',
      component_type: '',
      new_modal_count: 0,
      edit_modal_count: 0,
      positions: {
        clientX: undefined,
        clientY: undefined,
        movementX: 0,
        movementY: 0
      }
    }
  },
  computed: {
    ...mapState([
      'selection_process_tree', 'selection_process', 'stages', 'states', 'actions', 'progressions', 'errors', 'status'
    ]),
    filteredStages() {
      return this.stages.filter( _ => _.name.toLowerCase().includes(this.search_term.toLowerCase()))
    },
    filteredStates() {
      return this.states.filter( _ => _.name.toLowerCase().includes(this.search_term.toLowerCase()))
    },
    filteredActions() {
      return this.actions.filter( _ => _.name.toLowerCase().includes(this.search_term.toLowerCase()))
    },
    filteredProgressions() {
      return this.progressions.filter( _ => _.name.toLowerCase().includes(this.search_term.toLowerCase()))
    },
    stageIds() {
      return this.selection_process_tree.map(_ => _.id)
    }
  },
  methods: {
    editItem(item, item_type) {
      this.editable_item = item;
      this.component_type = this.editable_type = item_type;
      if(item_type == 'action') this.component_type = 'transition'
      this.edit_modal_count++
      this.$refs.editable.show()
    },
    newItem(event, item_type) {
      event.stopPropagation();
      this.component_type = this.newable_type = item_type
      if(item_type == 'action') this.component_type = 'transition'
      this.new_modal_count++
      this.$refs.newable.show()
    },
    clone(original){
      var element = {}
      for (var key in original) {
        if(original.hasOwnProperty(key)) element[key] = JSON.parse(JSON.stringify(original[key]))
      }
      return element;
    },
    allowMove(event) {
      var stage_id = event.draggedContext.element.id
      if(this.stageIds.includes(stage_id)) return false
    },
    dragMouseDown: function (event) {
      event.preventDefault()
      this.positions.clientX = event.clientX
      this.positions.clientY = event.clientY
      document.onmousemove = this.elementDrag
      document.onmouseup = this.closeDragElement
    },
    elementDrag: function (event) {
      event.preventDefault()
      this.positions.movementX = this.positions.clientX - event.clientX
      this.positions.movementY = this.positions.clientY - event.clientY
      this.positions.clientX = event.clientX
      this.positions.clientY = event.clientY
      this.$refs.draggableContainer.style.top = (this.$refs.draggableContainer.offsetTop - this.positions.movementY) + 'px'
      this.$refs.draggableContainer.style.left = (this.$refs.draggableContainer.offsetLeft - this.positions.movementX) + 'px'
    },
    closeDragElement () {
      document.onmouseup = null
      document.onmousemove = null
    }
  },
  created() {
    this.$store.dispatch('sidebar')
    window.addEventListener("resize", () => {
      if(window.innerWidth > 1400) {
        this.$refs.draggableContainer.style.top = '';
        this.$refs.draggableContainer.style.right = '';
        this.$refs.draggableContainer.style.left = '';
      }
    });
  }
}
</script>

<style lang="scss" scoped>
.right-sidebar {
  position: absolute;
  right: 0;
  top: -24px;
  width: 305px;
  background: white;
  padding: 13px 0px;
  z-index: 1001;
  min-height: 100vh;
  .movable { display: none; }
  @media screen and (max-width: 900px) {
    display: none;
  }
  @media screen and (max-width: 1400px) {
    border: 1px solid #eeeeee;
    position: fixed;
    top: 150px;
    right: 35px;
    transition: 200ms width linear;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0);
    min-height: inherit;
    .movable { display: block; position: absolute; top: -28px; right: -1px; }
  }
  .item-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-radius: 5px;
    cursor: pointer;
    padding: 0;
    height: 35px;
    margin: 5px 20px 2px 20px;
    border: 1px solid white;
    background: white;

    &:hover {
      background: #f9f9f9;
      transition: background 0.3s ease;
      border: 1px solid #f9f9f9;
    }
  }
  .item-list {
    max-height: 255px;
    overflow-y: auto;
    margin-top: 5px;

    .item {
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0);
      height: 35px;
      display: flex;
      padding: 0 15px;
      margin: 2px 10px 8px 20px;
      transition: all 0.3s cubic-bezier(.25,.8,.25,1);
      border-radius: 4px;
      cursor: grab;
      background: white;
    }
    .item:hover {
      box-shadow: 0 14px 28px rgba(0,0,0,0.12), 0 10px 10px rgba(0,0,0,0);
    }
  }
}
.search {
  margin: 0 20px;
}

.item-list::-webkit-scrollbar-thumb {
  border-radius: 8px;
  border: 2px solid white;
  background-color: rgba(0, 0, 0, .5);
}
.item-list::-webkit-scrollbar {
  -webkit-appearance: none;
}
.item-list::-webkit-scrollbar:vertical {
  width: 10px;
}
</style>

<style>
:host .tag-button button div:hover {
  background: green;
}
</style>