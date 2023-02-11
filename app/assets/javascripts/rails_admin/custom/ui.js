// override this file in your application to add custom behaviour

//= require 'selectize.min'
//= require 'thecore_ui_commons'

const adjustIframe = function(obj) {
    obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
};

// // Re evaluate at each iteration
// $(document).on('rails_admin.dom_ready', function () {
//     // If the page loaded has a tag like <span class="hide-breadcrumb hide-toolbar"></span>
//     // then hide the elements
//     if ($(".hide-breadcrumb").length) $(".breadcrumb").hide()
//     else $(".breadcrumb").show()

//     if ($(".hide-toolbar").length) $(".breadcrumb + .nav.nav-tabs").hide()
//     else $(".breadcrumb + .nav.nav-tabs").show()
// });

//= require 'rails_admin/custom/thecore/ui'