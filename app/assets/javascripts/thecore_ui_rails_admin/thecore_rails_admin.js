//= require timer
//= require thecore_ui_commons/thecore
//= require_tree .

$(document).on('ready pjax:success', function(e) {
  handleActiveBase();

  function handleActiveBase() {
    $('.sub-menu').each(function() {
      if ($(this).hasClass('active')) {
        $(this).parent().prev().addClass('active');
        $(this).parent().prev().addClass('open');
        $(this).parent().slideDown();
      }
    });
  }
  // home dashboard dark theme
  if ((new RegExp('app/$').test(e.currentTarget.URL) || new RegExp('app$').test(e.currentTarget.URL)) && !new RegExp('app/app').test(e.currentTarget.URL)) {
    $('.page-header, .content').addClass('dashboard');
  } else {
    $('.page-header, .content').removeClass('dashboard');
  }
});

$(function() {
  var array_menu = [];
  var lvl_1 = null;
  var count = 0;

  $('.sidebar-nav li').each(function(index, item) {
    if ($(item).hasClass('dropdown-header')) {
      lvl_1 = count++;
      array_menu[lvl_1] = []
    } else {
      $(item).addClass('sub-menu sub-menu-' + lvl_1);
    }
  });

  for (var i = 0; i <= array_menu.length; i++) {
    $('.sub-menu-' + i).wrapAll("<div class='sub-menu-container' />");
  }

  $('.sub-menu-container').hide();

  handleActiveBase();

  function handleActiveBase() {
    $('.sub-menu').each(function() {
      if ($(this).hasClass('active')) {
        $(this).parent().prev().addClass('active');
        $(this).parent().slideDown();
      }
    });
  }

  $('.dropdown-header').bind('click', function() {
    $('.dropdown-header').removeClass('open'); //Rimuove tutte le classi open
    $(this).toggleClass('open'); // Apre la corrente
    // Se la corrente è già aperta, allora la chiude

    $('.dropdown-header').removeClass('active');
    $('.sub-menu-container').stop().slideUp();
    $(this).toggleClass('active');
    $(this).next('.sub-menu-container').stop().slideDown();
  });
});

$(document).ready(function () {
  // All pjax in sidebar-nav make the menu disappear when clicked
  $(".sidebar-nav a[class=pjax]").on("click", function(){
    $('#wrapper').toggleClass('toggled');
  });

  $('#sidebar-collapse').on('click', function() {
    $('#wrapper').toggleClass('toggled');
  });

});
