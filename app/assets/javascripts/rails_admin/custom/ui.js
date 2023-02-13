// override this file in your application to add custom behaviour

//= require 'selectize.min'
//= require 'thecore_ui_commons'

const adjustIframe = function(obj) {
    obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
};

//= require 'rails_admin/custom/thecore/ui'