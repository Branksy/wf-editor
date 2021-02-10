export default {
  methods: {
    reenableForm() {
      var values = this.$refs.form.getFieldValues()
      this.$refs.form.clear()
      this.$refs.form.setFieldValues(values)
    },
    clearForm() {
      var form_options = { ...this.$data.form }
      Object.assign(this.$data, this.$options.data())
      this.form = form_options
    }
  }
}