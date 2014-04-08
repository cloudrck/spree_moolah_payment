SpreeMoolah = {
  hidePaymentSaveAndContinueButton: function(paymentMethod) {
    if ( (paymentMethod.val() == SpreeMoolah.paymentMethodID) ||
         (typeof SpreePaypalExpress === 'object' && paymentMethod.val() == SpreePaypalExpress.paymentMethodID)
       ) {
      $('#checkout_form_payment .continue').hide();
    } else {
      $('#checkout_form_payment .continue').show();
    }
  }
};

$(document).ready(function() {
  checkedPaymentMethod = $('div[data-hook="checkout_payment_step"] input[type="radio"]:checked');
  SpreeMoolah.hidePaymentSaveAndContinueButton(checkedPaymentMethod);
  paymentMethods = $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    SpreeMoolah.hidePaymentSaveAndContinueButton($(e.target));
  });
});
