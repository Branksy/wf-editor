import Vue from 'vue';

Vue.filter('titleize', function (value) {
  if (!value) return ''
  value = value.toString()
  return value.charAt(0).toUpperCase() + value.slice(1)
});

Vue.filter('formatDate', function (utc_string) {
  return new Date(utc_string).toDateString();
});
