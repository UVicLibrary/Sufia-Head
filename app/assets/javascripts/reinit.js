$(document).bind('page:change', function() {
  $('.ck_editor').each(function() {
    CKEDITOR.replace($(this).attr('id'));
  });
});