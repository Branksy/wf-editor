
<template lang='pug'>
div
  h3 Selection Processes
  .flex.end
    tag-button(accent='coral' text='Create new' icon='Plus' icon-accent='white' style='justify-self: flex-end'  @click='$refs.new.clearForm();$refs.new_workflow.show()')

  tag-modal(ref='new_workflow' width='small' border-accent='coral' heading='New Selection Process' header-option-4='' header-option-4-text='' header-option-4-accent=''  header-option-4-rounded-background-accent='')
    new-selection-process(ref='new')

  br
  br
  tag-card(version='2' accent='white')
    table(style='width: 100%;')
      thead
        tr(style='height:55px;border-bottom: 1px solid #efecec')
          th Name
          //- th Title
          th Abbr
          //- th Description
          th Created
          th
          th
          th
      tbody
        template
          tr.hoverable(v-for='sp in selection_processes' style='height:55px;border-bottom: 1px solid #efecec')
            td(style='font-size: 14px; color: #4B4E52') {{ sp.name.toUpperCase() }}
            //- td(style='font-size: 14px; color: #4B4E52') {{ sp.title }}
            td {{ sp.abbreviation }}
            //- td {{ sp.description }}
            td {{ sp.created_at | formatDate }}
            td
              vtag-pill {{ sp.status | titleize }}
            td
              router-link(:to="{name: 'designer_path', params: {id: sp.id}}")
                tag-button(icon='Edit' size='small' rounded)
            td
              tag-button(icon='Delete' size='small' rounded small)

</template>

<script>
import vtagPill from '../components/vtag_pill'
import NewSelectionProcess from './selection_processes/new'
import { mapState } from 'vuex'

export default {
  components: {
    vtagPill,
    NewSelectionProcess
  },
  methods: {
    getData() {

    },
  },
  computed: {
    ...mapState(['selection_processes'])
  },
  created() {
    this.$store.dispatch('index')
    this.$store.commit('RESET_EDIT_MODE')
    this.getData()
  }
}
</script>

<style scoped>
.accent--title {
  color: green;
}
th { background: white !important;}
th:nth-child(1), td:nth-child(1) {
  padding-left: 20px;
}
</style>