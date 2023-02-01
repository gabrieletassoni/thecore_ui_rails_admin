// override this file in your application to add custom behaviour

$(document).on('turbolinks:load', function(){
    $(".alert" ).fadeOut(3000);
});

//= require 'rails_admin/custom/thecore/ui'
