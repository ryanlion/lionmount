$(document).on('ready page:load', function () {
  window.ParsleyValidator
    .addValidator('decimal', function(val, requirement) {
      var reg = /^\s*-?[1-9]\d*(\.\d{1,2})?\s*$/;
      return reg.test(val);
    })
    .addMessage('en', 'decimal', "Please enter only number and decimal.")
  function initializeFormValidation() {
    $(".form-validation").each(function() {
      var $form = $(this);
      $form.parsley({
        namespace: 'data-'
      }).subscribe('parsley:form:validate', function (formInstance) {
        // enable placeholders after validation is error for IE
        if (!formInstance.isValid()) {
          Placeholders.enable();
        }
      });
      // this 3 lines caused http://dev.appcara.com/issues/11240
      // not sure if it is still needed, tested some form and seems fine
      $form.data('validate', function() {
        return $form.parsley().validate();
      });
    });

    $(".form-validation input:not([type=radio]),textarea").focusout(function() {
      var $field = $(this);
      $field.attr("data-parsley-namespace", "data-");
      $field.parsley().validate();
      $field.parsley().asyncValidate();
    });
    initializeValidaterepeat();
    $('body').off('click', '.resolve_value').on('click',".resolve_value",function(){
      var command = $(this).parent().parent().parent().find("input").data("resolve-command"); // need to revise
      var target_item = $(this).parent().parent().parent().find("input");
      if (command.search("same_group")!= -1) {
        var group = $(this).parent().parent().parent().find("input").data("match_with")[1];
        command =  command.replace("same_group",group);
      };
      if (command.search("self")!= -1) {
        command =  command.replace("self",'target_item');
      };
      eval(command);
      target_item.parsley().validate();
    });

  }
  // initialize repeat items validation
  function initializeValidaterepeat(){
   validatedTargets =  $(".form-validation").find(".key_item");
      $.each(validatedTargets, function(){
        var $field = $(this);
        $field.parsley().validate();
      });
  }


  $('body').on('statechanged', initializeFormValidation);
  $('body').on('focusout',".key_item", initializeValidaterepeat);

  initializeFormValidation();

  // auto trigger validation of another field after change
  $('body').on('change', '[data-trigger-validate]', function(event) {
    var sel = $(this).data('trigger-validate');
    $(sel).each(function() {
      $(this).data('Parsley').validate();
    });
  });

  $('body').on('click', '.validate-and-warning', function(event) {
    var $form = $(this).parents('form');
    var valid = $form.parsley().isValid();
    var self = $(this);
    if (!valid) {
      var output = "";
      $form.parsley().fields.forEach(function(x) {
          if (x.$element.parents(self.attr('validation-scope')).length == 0) {
            output += '';
          }
          else {
            if (!x.isValid()) {
              var t = x.$element.attr('validation_table') + ' ' + x.$element.attr('validation_attribute');
              var id = x.$element.prop('id');
              if (id) {
                var $label = $('label[for=' + id + ']');
                if (!!$label.length) { t = $label.text(); }
              }
              output += 'Item ' + t + " is invalid.\n";
            }
          }
      });
      if (output == "") {
        return true;
      }
      else {
        alert(output);
        event.stopImmediatePropagation();
        return false;
      }
    }
  });
});
