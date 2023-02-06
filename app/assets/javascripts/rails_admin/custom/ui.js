// override this file in your application to add custom behaviour

console.log("Thecore UI Rails Admin")

function hideBreadCrumbAndToolbar() {
    // If the page loaded has a tag like <span class="hide-breadcrumb hide-toolbar"></span>
    // then hide the elements

    // var actionName = "#{action_name}"
    // var isRoot = "#{RailsAdmin::Config::Actions.find(action_name.to_sym).root?}"

    // console.log(actionName, isRoot)

    if ($(".hide-breadcrumb").length) $(".breadcrumb").hide()
    else $(".breadcrumb").show()

    if ($(".hide-toolbar").length) $(".breadcrumb + .nav.nav-tabs").hide()
    else $(".breadcrumb + .nav.nav-tabs").show()
}


function adjustIframe(obj) {
    obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
}

// Re evaluate at each iteraction
$(document).off('ready pjax:success', hideBreadCrumbAndToolbar);
$(document).on('ready pjax:success', hideBreadCrumbAndToolbar);

//= require 'rails_admin/custom/thecore/ui'