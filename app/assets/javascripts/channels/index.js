// Expose action cable
//= require actioncable
//= require_self
//= require_tree ../channels

// import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = false;

window.App || (window.App = {});
window.App.cable = ActionCable.createConsumer();

console.log("Action Cable Exposed");